////
////  ListPhotoViewController.swift
////  ListPhoto
////
////  Created by Vũ Đức on 16/12/24.
////
import UIKit
import Combine

class ListPhotoViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    let viewModel: PhotoViewModel
    let cellPhoto = "PhotoTableViewCell"
    
    init(viewModel: PhotoViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let amountPagelb = UILabel()
    lazy var photoTableView = UITableView()
    let searchBar = UISearchBar()
    private let delegateMultiplexer = SearchBarDelegateMultiplexer()
    private let saveIndexPathSubject = CurrentValueSubject<IndexPath, Never>(IndexPath(row: 0, section: 0))
    private let saveText = CurrentValueSubject<String, Never>("")
    private let refreshControl = UIRefreshControl()
    
    private var lastContentOffset: CGPoint = .zero
    private let scrollThreshold: CGFloat = 4000.0
    private var lastScrollTime: TimeInterval = 0
    private let scrollTimeThreshold: TimeInterval = 0.1
    private var isScrollingFast: Bool = false
    private var searchWorkItem: DispatchWorkItem?
    
    private let loadInitialSubject = PassthroughSubject<Void, Never>()
    private let searchSubject = PassthroughSubject<(String, Bool), Never>()
    private let refreshSubject = PassthroughSubject<Void, Never>()
    private let loadMoreSubject = PassthroughSubject<Void, Never>()
    
    private var wasScrollingFast: Bool = false
    private var isUserInterruptingScroll: Bool = false
    private var reloadWorkItem: DispatchWorkItem?
    
    private var statusNetWork:NetworkStatus = .disconnected
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configNavigationBar()
        addView()
        setUpView()
        bindViewModel()
        combineNetwork()
        combineTextField()
        loadInitialSubject.send(())
    }
    
    private func bindViewModel() {
        let initialFetch = loadInitialSubject.eraseToAnyPublisher()
        let searchTrigger = searchSubject.eraseToAnyPublisher()
        let refreshTrigger = refreshSubject.eraseToAnyPublisher()
        let loadMoreTrigger = loadMoreSubject.eraseToAnyPublisher()
        
        let input = PhotoViewModel.Input(initialFetch: initialFetch,
                                         refresh: refreshTrigger,
                                         loadMore: loadMoreTrigger,
                                         searchText: searchTrigger)
        
        let output = viewModel.transform(input: input)
        output.result
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self = self else { return }
                
                switch result.type {
                case .initial: self.photoTableView.reloadData()
                    
                case .loadMore(let firtIndex, let lastIndex):
                    let indexPaths = (firtIndex..<lastIndex).map{ IndexPath(row: $0, section: 0) }
                    self.photoTableView.insertRows(at: indexPaths, with: .automatic)
                case .search(let endSearching):
                    self.photoTableView.reloadData()
                    if !endSearching {
                        let indexPath = self.saveIndexPathSubject.value
                        self.photoTableView.scrollToRow(at: indexPath,
                                                        at: .top,
                                                        animated: true)
                        self.viewModel.pageInfoSubject.send("\(indexPath.row)/\(viewModel.listPhoto.count)")
                    } else {
                        if self.viewModel.listPhoto.count == 0 {
                            return
                        }
                        self.photoTableView.scrollToRow(at: IndexPath(row: 0, section: 0),
                                                        at: .top,
                                                        animated: true)
                    }
                case .refresh:
                    self.refreshControl.endRefreshing()
                    guard self.viewModel.listPhoto.count != 0 else {
                        self.loadInitialSubject.send(())
                        return
                    }
                    self.photoTableView.reloadData()
                }
                
            }.store(in: &disposeBag)
        
        output.error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                guard let self = self else { return }
                self.showAlert(title: "Error", message: message.messageError)
                self.refreshControl.endRefreshing()
            }
            .store(in: &disposeBag)
        
        output.loading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                guard let self = self else { return }
                self.showIndicator(status: isLoading)
            }
            .store(in: &disposeBag)
        
        output.pageInfo
            .receive(on: DispatchQueue.main)
            .sink { [weak self] pageInfo in
                guard let self = self else { return }
                self.amountPagelb.text = pageInfo
            }
            .store(in: &disposeBag)
        
    }
    
    func combineTextField() {
        let searchEvents = searchBar
            .searchEventsPublisher
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .share()
        
        let searchText = searchEvents
            .compactMap { [weak self] event -> String? in
                if case .textDidChange(let text) = event {
                   return text
                }
                return nil
            }
            .eraseToAnyPublisher()
        
        let endSearching = searchEvents
            .map { [weak self] event -> Bool in
                guard let self = self else { return false }
                switch event {
                case .cancelButtonClicked: self.searchBar.endEditing(true)
                case .endEditing: return self.searchBar.text?.isEmpty == true
                default : return false
                }
                return false
            }.eraseToAnyPublisher()
        
        Publishers.CombineLatest(searchText,
                                 endSearching)
        .sink { [weak self] (searchText, endSearching) in
            guard let self = self,
            searchText != self.saveText.value else { return }
            
            self.searchSubject.send((searchText, searchText == "" ? true : endSearching))
            self.saveText.send(searchText)
        }
        .store(in: &disposeBag)
    }
}

// MARK: Setup View - Constraint
extension ListPhotoViewController {
    func configNavigationBar() {
        self.navigationController?.navigationBar.backItem?.title = ""
        self.navigationController?.navigationBar.backgroundColor = .white
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
        searchBar.placeholder = "Search Author..."
        searchBar.barTintColor = .white
        searchBar.tintColor = .red
        searchBar.showsCancelButton = true
        if #available(iOS 13.0, *) {
            searchBar.searchTextField.keyboardType = .alphabet
        } else {
            if let textField = searchBar.value(forKey: "searchField") as? UITextField {
                textField.keyboardType = .alphabet
            }
        }
        searchBar.sizeToFit()
        searchBar.translatesAutoresizingMaskIntoConstraints = false

        searchBar.searchTextField.delegate = self
        
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
        photoTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.photoTableView.topAnchor.constraint(equalTo: self.searchBar.bottomAnchor, constant: 0),
            self.photoTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0),
            self.photoTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            self.photoTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
        ])
    }
    
    func configureAmountPagelb() {
        amountPagelb.text = "0"
        amountPagelb.backgroundColor = .gray
        amountPagelb.textColor = .white
        amountPagelb.textAlignment = .center
        amountPagelb.layer.cornerRadius = 15
        amountPagelb.clipsToBounds = true
        amountPagelb.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.amountPagelb.topAnchor.constraint(equalTo: self.photoTableView.topAnchor, constant: 15),
            self.amountPagelb.trailingAnchor.constraint(equalTo: self.photoTableView.trailingAnchor, constant: -2.5),
            self.amountPagelb.heightAnchor.constraint(equalToConstant: 35),
            self.amountPagelb.widthAnchor.constraint(equalToConstant: 80)
        ])
    }
}

// MARK: TableView DataSource
extension ListPhotoViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.listPhoto.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellPhoto, for: indexPath) as! PhotoTableViewCell
        let item = viewModel.listPhoto[indexPath.row]
        let height = viewModel.prefixNumber(number: item.height)
        cell.bindingData(
            with: item,
            height: height,
            isScrollingFast: isScrollingFast
        )
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = viewModel.listPhoto[indexPath.row]
        let height = viewModel.prefixNumber(number: item.height)
        return CGFloat(height + 80)
    }
}

extension ListPhotoViewController {
    func combineNetwork() {
        _ = NetworkMonitor.shared.publisher
            .receive(on: DispatchQueue.main)
            .sink { current in
                switch current {
                case .strongConnection:
                    if self.viewModel.listPhoto.count == 0 {
                        self.loadInitialSubject.send()
                    } else {
                        self.photoTableView.reloadData()
                    }
                case .weakConnection:
                    if self.viewModel.listPhoto.count == 0 {
                        self.loadInitialSubject.send()
                    } else {
                        self.photoTableView.reloadData()
                    }
                case .disconnected: break;
                case .normal: break;
                }
            }.store(in: &disposeBag)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard (self.viewModel.listPhoto.count != 0) else { return }
        // Cập nhật nhãn số trang
        if let firstVisibleIndexPath = photoTableView.indexPathsForVisibleRows?.first {
            amountPagelb.text = "\(firstVisibleIndexPath.row + 1)/\(viewModel.listPhoto.count)"
            
            if !viewModel.isFiltering {
                saveIndexPathSubject.send(firstVisibleIndexPath)
            }
        }
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.height
        if offsetY > (contentHeight - frameHeight * 2),
           !viewModel.loadingSubject.value,
           contentHeight != 0
        {
            loadMoreSubject.send(())
        }
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.searchBar.endEditing(true)
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard !isScrollingFast,
              abs(velocity.y) > 3.5 else { return }
        isScrollingFast = true
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if isScrollingFast {
            isScrollingFast = false
            self.photoTableView.reloadData()
        }
    }
}

// MARK: SearchBar Delegate
extension ListPhotoViewController: UISearchBarDelegate, UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard let currentText = textField.text,
              let textRange = Range(range, in: currentText) else { return true }
        
        // Text mới nếu áp dụng thay đổi
        let updatedText = currentText.replacingCharacters(in: textRange, with: string)
        
        // Chỉ cho phép ký tự hợp lệ
        let validCharacters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*():.,<>/\\[]? "
        let filteredText = updatedText.filter { validCharacters.contains($0) }
        
        // Loại bỏ dấu
        let noDiacritics = viewModel.removeDiacritics(from: filteredText) { [weak self] _ in
            self?.showAlert(title: "Thông báo", message: "Vui lòng không nhập ký tự có dấu!")
        }
        
        // Loại bỏ emoji và &
        let cleanedText = viewModel.removeAmpersandEntity(from: noDiacritics) { [weak self] _ in
            self?.showAlert(title: "Thông báo", message: "Vui lòng không nhập ký tự & hoặc emoji!")
        }
        
        // Giới hạn độ dài
        if cleanedText.count > 15 {
            textField.text = String(cleanedText.prefix(15))
            return false
        }
        textField.text = cleanedText

        NotificationCenter.default.post(name: UITextField.textDidChangeNotification,
                                        object: searchBar.searchTextField)
        return false
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        NotificationCenter.default.post(name: Notification.Name("SearchBarCancel"),
                                        object: searchBar)
    }
}

// MARK: Function
extension ListPhotoViewController {
    func showIndicator(status: Bool) {
        PresentViewQR.shared.showView(show: status)
    }
    
    @objc func refreshData() {
        refreshSubject.send(())
    }
}
