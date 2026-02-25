//
//  LSDEventsViewController.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 28/06/24.
//

import UIKit

class LSDEventsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    private var requestbody = LSRequstEvents()
    private var debounceTimer: Timer?

    private let viewModel = LSDEventViewModel()
    private var filterVC: LSDEventsFilterViewController?
    private let refreshControl = UIRefreshControl()
    private var currentPage = 1
    private var limit = 20

    var isLoading = false // Tracks if an API call is in progress

    let loadingIndicator = UIActivityIndicatorView(style: .medium)

    private var isSearching: Bool  {
        get {
            let searching = self.searchBar.text?.count ?? 0 > 0
            print("Is Searching = ", searching)
            return searching
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshList), for: .valueChanged)
        setupSearchBar()
        setupNavigationBarItems()
        initializeTableView()
        setupLoadingIndicator()
        // Do any additional setup after loading the view.
        fetchAllEvents()
        initializeFilterVC()
    }
    
    func setupLoadingIndicator() {
          loadingIndicator.hidesWhenStopped = true
          loadingIndicator.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44)
          tableView.tableFooterView = loadingIndicator
      }
    
    private func setupNavigationBarItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem.logoBarButtonItem()
        let profileButton = UIBarButtonItem.profileBarButtonItem(target: self, action: #selector(showProfileVC))
        let notificationButton = UIBarButtonItem.notificationBarButtonItem(target: self, action: #selector(showNotificationsVC))
        navigationItem.rightBarButtonItems = [profileButton, notificationButton]
    }
    
    private func initializeTableView() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150 // Estimate row height
        tableView.register(NoDataCell.self, forCellReuseIdentifier: "cell")
    }
    
    private func setupSearchBar() {
        // Change the background color of the search bar
        searchBar.backgroundImage = UIImage()
        searchBar.backgroundColor = .white
        searchBar.delegate = self
        // Change the background color of the search field
        if let searchTextField = searchBar.value(forKey: "searchField") as? UITextField {
            searchTextField.backgroundColor = .white
        }
    }
    
    @objc func refreshList() {
        if (searchBar != nil), (viewModel != nil) {
            self.currentPage = 1
            searchBar.text = ""
            requestbody = LSRequstEvents()
            searchBar.resignFirstResponder()
            fetchAllEvents()
        }
    }
    
    private func fetchAllEvents() {
        LSProgress.show(in: self.view)

        Task {
            do {
                requestbody.searchByTripIdEventIdEventType = searchBar.text
                print("Post Parms = ", requestbody)
                try await viewModel.fetchAllEvents(parameters: ["page": String(currentPage), "limit": String(limit)], requestbody: requestbody)
                DispatchQueue.main.async {
                    self.tableView.delegate = self
                    self.tableView.dataSource = self
                    self.reloadTable()
                    self.refreshControl.endRefreshing()
                    LSProgress.hide(from: self.view)
                }
            } catch {
                print("error = ", error)
                UIAlertController.showError(on: self, message: String(error.localizedDescription))
                self.tableView.delegate = self
                self.tableView.dataSource = self
                self.reloadTable()
                self.refreshControl.endRefreshing()
                LSProgress.hide(from: self.view)
            }
        }
    }
    
    private func loadMoreEvents() {
        guard !isLoading else { return } // Prevent duplicate API calls
        isLoading = true

        loadingIndicator.startAnimating()

        Task {
            do {
                requestbody.searchByTripIdEventIdEventType = searchBar.text
                try await viewModel.loadMoreEvents(parameters: ["page": String(currentPage), "limit": String(limit)], requestbody: requestbody)
                DispatchQueue.main.async {
                    self.reloadTable()
                    self.loadingIndicator.stopAnimating()
                    self.isLoading = false
                }
            } catch {
                self.loadingIndicator.stopAnimating()
                self.isLoading = false
            }
        }
    }
    
    private func reloadTable() {
        self.tableView.reloadData()
    }
    
    private func initializeFilterVC() {
         filterVC = LSDEventsFilterViewController.instantiate(fromStoryboard: .driver)
        if let sheet = filterVC?.sheetPresentationController {
            sheet.detents = [.large()] // .medium() will present half the screen
            sheet.prefersGrabberVisible = true // Optional: Show a grabber at the top of the sheet
            sheet.prefersEdgeAttachedInCompactHeight = true
            filterVC?.preferredContentSize = CGSize(width: self.view.frame.size.width, height: 500)
        }
        filterVC?.filterDelegate = self
    }
        
    @IBAction func filterAction(_ sender: Any) {
        self.view.endEditing(true)

        if let filterVC = filterVC {
            present(filterVC, animated: true, completion: nil)
        }
    }
    
   
}
extension LSDEventsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let eventsCount = viewModel.numberOfRows()
        if eventsCount > 0 {
            return eventsCount
        }
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let eventsCount = viewModel.numberOfRows()
        if eventsCount > 0 {
            return self.tableView(tableView, eventsCellForRowAt: indexPath)
        }
        return self.tableView(tableView, noDataCellForRowAt: indexPath)

    }
    
    func tableView(_ tableView: UITableView, eventsCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LSDEventTableViewCell", for: indexPath) as? LSDEventTableViewCell else {
            return UITableViewCell()
        }

        let event = viewModel.itemAt(indexPath:indexPath)
        cell.configure(with: event, tableView: tableView)
        return cell
    }
    
    func tableView(_ tableView: UITableView, noDataCellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let noDataFound = UILabel.init(frame: tableView.bounds)
        noDataFound.backgroundColor = .appBackground
        noDataFound.text = "Data not available"
        noDataFound.textAlignment = .center
        noDataFound.textColor = .lightGray
        cell.addSubview(noDataFound)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.view.endEditing(true)
        let eventDetailsVC = LSDEventDetailsViewController.instantiate(fromStoryboard: .driver)
        let event = viewModel.itemAt(indexPath:indexPath)
        eventDetailsVC.event = event
        self.navigationController?.pushViewController(eventDetailsVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.numberOfRows() - 1 { // Last cell
            if let pageDetails = viewModel.pageDetails, viewModel.numberOfRows() < pageDetails.totalRecords, !isLoading {
                print("Number of Rows = ", viewModel.numberOfRows())
                print("totalRecords = ", pageDetails.totalRecords)
                currentPage += 1
                loadMoreEvents()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension LSDEventsViewController: LSDEventsFilterDelegate {
    func didtapOnSearch(requestBody: LSRequstEvents) {
        self.view.endEditing(true)
        currentPage = 1
        self.requestbody = requestBody
        self.fetchAllEvents()
    }
        
    func didtapOnClearFilter() {
        self.currentPage = 1
        self.requestbody = LSRequstEvents()
        self.fetchAllEvents()
    }
}

extension LSDEventsViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        debounceTimer?.invalidate() // Invalidate any existing timer
        // Create a new debounce timer
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false) { [weak self] _ in
            self?.currentPage = 1
//            self?.requestbody = LSRequstEvents()
            self?.fetchAllEvents()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
//        self.requestbody = LSRequstEvents()
        self.fetchAllEvents()
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
