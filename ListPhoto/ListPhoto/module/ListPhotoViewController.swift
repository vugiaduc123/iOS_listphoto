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
    private var isScrollingFast: Bool = false
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
        viewModel.getlistPhoto(placeHolder: { [weak self] placeHolder in
            guard let self = self else { return }
            if placeHolder == false {
                DispatchQueue.main.async {
                    self.photoTableView.reloadData()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                        self.showIndicator(status: false)
                        self.amountPagelb.text = "1/\(self.viewModel.listPhoto.count)"
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
        //        photoTableView.prefetchDataSource = self
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
        let height = viewModel.prefixNumber(number: item.height)
        cell.bindingData(with: item,
                         height: height,
                         downloader:
                            viewModel.downloader,
                         isScrollingFast: isScrollingFast)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = viewModel.listPhoto[indexPath.row]
        let height = viewModel.prefixNumber(number: item.height)
        return CGFloat(height + 80)
    }
    
    //    // This function will be called when the scroll view changes
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
        let visibleIndexPaths = photoTableView.indexPathsForVisibleRows ?? []
        if let firstVisibleIndexPath = visibleIndexPaths.first {
            amountPagelb.text = "\(firstVisibleIndexPath.row + 1)/\(viewModel.listPhoto.count)"
        }
        let currentTime = Date().timeIntervalSince1970
        let timeDifference = currentTime - lastScrollTime
        if timeDifference > scrollTimeThreshold {
            let offsetDifference = scrollView.contentOffset.y - lastContentOffset.y
            let speed = abs(offsetDifference) / CGFloat(timeDifference)
            isScrollingFast = speed > scrollThreshold
            lastContentOffset = scrollView.contentOffset
            lastScrollTime = currentTime
        }
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        if offsetY > contentHeight - frameHeight * 2, !viewModel.isLoadIndicator {
            viewModel.isLoadIndicator = true
            showIndicator(status: true)
            viewModel.getLoadMore(page: viewModel.page + 1, limit: 100) { [weak self] place in
                if !place {
                    DispatchQueue.main.async {
                        self?.photoTableView.reloadData()
                        self?.viewModel.page += 1
                        self?.viewModel.isLoadIndicator = false
                        self?.showIndicator(status: false)
                    }
                }
            }
        }
    }
}

extension ListPhotoViewController: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) { for indexPath in indexPaths {
        let photo = viewModel.listPhoto[indexPath.row]
        if let normalizedUrl = URL(string: photo.download_url)?.absoluteString { viewModel.downloader.download( url: normalizedUrl, completionTask: { _ in }, placeholder: { _ in }, completion: { _ in } ) }
    }
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

