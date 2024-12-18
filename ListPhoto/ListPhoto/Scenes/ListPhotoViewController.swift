//
//  ListPhotoViewController.swift
//  ListPhoto
//
//  Created by Vũ Đức on 16/12/24.
//

import UIKit

class ListPhotoViewController: UIViewController {

    let viewModel: PhotoViewModel
    let cellPhoto = "PhotoTableViewCell"

    init(viewModel: PhotoViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let amountPagelb = UILabel()
    lazy var photoTableView = UITableView()

    let searchBar = UISearchBar()
    var filteredData: [String] = []

    var refreshControl = UIRefreshControl()

    private var lastContentOffset: CGPoint = .zero
    private let scrollThreshold: CGFloat = 5000.0 // pixels per frame
    private var lastScrollTime: TimeInterval = 0
    private let scrollTimeThreshold: TimeInterval = 0.05 // estimate time
    private var isActiveLoadCell: Bool = false
    private var searchWorkItem: DispatchWorkItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        configNavigationBar()
        callAPI()
        addView()
        setUpView()
    }
}

// MARK: API Service
extension ListPhotoViewController {
    func callAPI() {
        self.showIndicator(status: true)
        viewModel.getlistPhoto(placeHolder: { placeHolder in
            if placeHolder == false {
                print("viewModel.listPhoto===\(self.viewModel.listPhoto)")
                DispatchQueue.main.async {
                    self.photoTableView.reloadData()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                        self.showIndicator(status: false)
                    })
                }
            }
        })
    }
}

// MARK: Setup View - Constraint
extension ListPhotoViewController {
    func configNavigationBar() {
        self.navigationController?.navigationBar.backItem?.title = ""
        self.navigationController?.navigationBar.changeBackgroundColor(backroundColor: UIColor.white)
        self.navigationItem.setHidesBackButton(true, animated: true)
    }

    func addView() {
        self.view.backgroundColor = .white
        self.view.addSubview(photoTableView)
        self.view.addSubview(amountPagelb)
        self.view.addSubview(searchBar)
    }

    func setUpView() {
        configurePhotTable()
        configureAmountPagelb()
        configSearchBar()
    }

    func configSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Search Author..."
        searchBar.barTintColor = UIColor.white
        searchBar.tintColor = .red
        searchBar.showsCancelButton = true
        searchBar.disableSwipeTyping()
        if #available(iOS 13.0, *) {
            searchBar.searchTextField.keyboardType = .alphabet
        } else {
            if let textField = searchBar.value(forKey: "searchField") as? UITextField {
                textField.keyboardType = .alphabet
            }
        }
        searchBar.sizeToFit()
        searchBar.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            self.searchBar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0),
            self.searchBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            self.searchBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            self.searchBar.heightAnchor.constraint(equalToConstant: 50),
        ])
    }

    func configurePhotTable() {
        photoTableView.register(PhotoTableViewCell.self, forCellReuseIdentifier: cellPhoto)
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        photoTableView.refreshControl = refreshControl
        photoTableView.dataSource = self
        photoTableView.delegate = self
        photoTableView.prefetchDataSource = self
        photoTableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            self.photoTableView.topAnchor.constraint(equalTo: self.searchBar.bottomAnchor, constant: 0),
            self.photoTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 10),
            self.photoTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            self.photoTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
        ])
    }

    func configureAmountPagelb(){
        amountPagelb.text = "0"
        amountPagelb.backgroundColor = .gray
        amountPagelb.textColor = .white
        amountPagelb.textAlignment = .center
        amountPagelb.layer.cornerRadius = 15
        amountPagelb.clipsToBounds = true
        amountPagelb.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            self.amountPagelb.topAnchor.constraint(equalTo: self.photoTableView.topAnchor, constant: 15),
            self.amountPagelb.trailingAnchor.constraint(equalTo: self.photoTableView.trailingAnchor, constant: 2.5),
            self.amountPagelb.heightAnchor.constraint(equalToConstant: 35),
            self.amountPagelb.widthAnchor.constraint(equalToConstant: 80)
        ])
    }
}

// MARK: TableView DataSource
extension ListPhotoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.listPhoto.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellPhoto, for: indexPath ) as! PhotoTableViewCell
        let item = viewModel.listPhoto[indexPath.row]
        if tableView.indexPath(for: cell) == indexPath {
            if isActiveLoadCell == false {
                cell.bindingData(item: item, viewModel: viewModel, indexPathScroll: tableView.indexPath(for: cell)!)
            }else {
                cell.imagePhoto.image = UIImage(named: "loading")
            }
        }else {
            cell.imagePhoto.image = UIImage(named: "loading")
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = viewModel.listPhoto[indexPath.row]
        let height = viewModel.prefixNumber(number: item.height)
        return CGFloat(height + 80)
    }

    // load more
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let location = scrollView.panGestureRecognizer.location(in: self.photoTableView)
        guard let indexPath = photoTableView.indexPathForRow(at: location) else {
            print("could not specify an indexpath")
            return
        }
        amountPagelb.text = "\(indexPath.row)/\(self.viewModel.listPhoto.count)"

        if viewModel.filteredData.count != 0 {
            return
        } // filter array no use loadmore
        let estimate = indexPath.row + viewModel.limitLoad
        if estimate > viewModel.listPhoto.count {
            if viewModel.isLoadIndicator == false {
                self.showIndicator(status: true)
                viewModel.isLoadIndicator.toggle()
                viewModel.getLoadMore(page: viewModel.limit, limit: 100) { [weak self] place in
                    guard let strongSelf = self else { return }
                    if place == false {
                        DispatchQueue.main.async {
                            strongSelf.photoTableView.reloadData()
                            strongSelf.viewModel.limit += 1
                            strongSelf.viewModel.isLoadIndicator = false
                            strongSelf.showIndicator(status: false)
                        }
                    }
                }
            }
        }
    }

    // This function will be called when the scroll view changes
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
        let currentTime = Date().timeIntervalSince1970
        let timeDifference = currentTime - lastScrollTime
        if timeDifference > scrollTimeThreshold {
            let offsetDifference = scrollView.contentOffset.y - lastContentOffset.y
            let speed = abs(offsetDifference) / CGFloat(timeDifference)
            if speed > scrollThreshold {
                print("User is scrolling fast!")
                self.isActiveLoadCell = true
            } else {
                print("User is scrolling slowly.")
                self.isActiveLoadCell = false
            }

            // Update position and time for next scroll
            lastContentOffset = scrollView.contentOffset
            lastScrollTime = currentTime
        }
    }
}

extension ListPhotoViewController: UITableViewDataSourcePrefetching {

    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        perfectRowAt(indexPaths: indexPaths)
    }

    // cancel when fast scoll
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        cancelPrefetchingForRowsAt(indexPaths: indexPaths)
    }
}

extension ListPhotoViewController: UITableViewDelegate {

}

// MARK: UISearchBarDelegate
extension ListPhotoViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let validCharacters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&amp;*():.,&lt;&gt;/\\[]? "
        let filteredText = searchText.filter { validCharacters.contains($0) }
//        let filteredText = validCharacters
        let removeTelex = viewModel.removeDiacritics(from: filteredText, completion: { result in
            self.showAlert(title: "Thông báo", message: "Vui lòng không được nhập kí tự có dấu!!!")
            return
        })
        let special = viewModel.removeAmpersandEntity(from: removeTelex, completion: {   result in
            self.showAlert(title: "Thông báo", message: "Vui lòng không được nhập có kiểu kí tự &amp; và emoji!!!")
            return
        })
        if special.count > 15 {
            searchBar.text = String(special.prefix(15))
            return
        }
        searchWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.performSearch(text: special)
        }
        searchWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
        searchBar.text = special
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false 
        viewModel.filterSearchBar(filter: false, tapCancel: true, stringFilter: "")
        self.photoTableView.reloadData()
        amountPagelb.text = "0/\(viewModel.listPhoto.count)"

    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.count > 1 {
            return false
        }
        return true
    }
}

// MARK: Function
extension ListPhotoViewController {
    func showIndicator(status: Bool) {
        if status {
            let indicator = viewModel.indicatorView(frame: self.view.frame)
            indicator.tag = 333
            self.view.addSubview(indicator)
        }else{
            if let viewWithTag = self.view.viewWithTag(333) {
                viewWithTag.removeFromSuperview()
            }
        }
    }

    func perfectRowAt(indexPaths: [IndexPath]) {
        if viewModel.listPhoto.count == 0 { return }
        if isActiveLoadCell == false {
            for indexPath in indexPaths {
                let maxRowsAhead = 10
                if indexPath.row < maxRowsAhead {
                    var dataTask: URLSessionDataTask?
                    print("Prefetching data for row: \(indexPath.row)")
                    viewModel.fetchData(indexPath: indexPath) { task in
                        dataTask = task
                    } placeHolder: { [weak self] place in
                        guard let strongSelf = self else { return }
                        if place == false {
                            if let task = dataTask {
                                strongSelf.viewModel.activeTasks[indexPath] = task
                            }
                        }
                    }
                }
            }
        }
    }

    func cancelPrefetchingForRowsAt(indexPaths: [IndexPath]) {
        if viewModel.listPhoto.count == 0 {
            return
        }
        if isActiveLoadCell == false {
            for indexPath in indexPaths {
                if let task = self.viewModel.activeTasks[indexPath] {
                    task.cancel()
                    self.viewModel.activeTasks[indexPath] = nil
                } else {
                    print("No task for this indexPath")
                }
            }
        }
    }

    @objc func refreshData() {
        self.showIndicator(status: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.showIndicator(status: false)
            self.viewModel.listPhoto.shuffle()
            self.photoTableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }

    func performSearch(text: String) {
        if text.isEmpty {
            viewModel.filterSearchBar(filter: false, tapCancel: false, stringFilter: "")
            self.photoTableView.reloadData()
            amountPagelb.text = "0/\(viewModel.listPhoto.count)"
        } else {
            viewModel.filterSearchBar(filter: true, tapCancel: false, stringFilter: text)
            amountPagelb.text = "0/\(viewModel.listPhoto.count)"
            self.photoTableView.reloadData()
        }

    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil)) // Nút OK
        self.present(alert, animated: true, completion: nil)
    }
}

