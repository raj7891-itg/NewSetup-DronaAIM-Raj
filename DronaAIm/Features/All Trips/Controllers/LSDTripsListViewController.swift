//
//  LSDTripsViewController.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 27/06/24.
//

import UIKit
import Toast

class NoDataCell: UITableViewCell {
    
}

class LSDTripsListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var filterVC: LSTripsFilterViewController?

    private let viewModel = LSDTripListViewModel()

    private var isSearching: Bool = false
    private let refreshControl = UIRefreshControl()

    private var requestbody = LSRequstTrips()
    private var currentPage = 1
    private var limit = 20
    private var debounceTimer: Timer?

    var isLoading = false // Tracks if an API call is in progress
    let loadingIndicator = UIActivityIndicatorView(style: .medium)

    override func viewDidLoad() {
        super.viewDidLoad()
//        self.title = "All Trips"
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshList), for: .valueChanged)

        tableView.register(NoDataCell.self, forCellReuseIdentifier: "cell")

        setupSearchBar()
        setupNavigationBarItems()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 230 // Estimate row height
        setupLoadingIndicator()
        fetchTripsList()
        initializeFilterVC()
    }
    
    func setupLoadingIndicator() {
          loadingIndicator.hidesWhenStopped = true
          loadingIndicator.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44)
          tableView.tableFooterView = loadingIndicator
      }
    
    private func setupSearchBar() {
        // Change the background color of the search bar
        searchBar.delegate = self // Add this line
        searchBar.backgroundImage = UIImage()
        searchBar.backgroundColor = .white
        
        // Change the background color of the search field
        if let searchTextField = searchBar.value(forKey: "searchField") as? UITextField {
            searchTextField.backgroundColor = .white
        }
    }
    
    private func initializeFilterVC() {
         filterVC = LSTripsFilterViewController.instantiate(fromStoryboard: .driver)
        if let sheet = filterVC?.sheetPresentationController {
            sheet.detents = [.large()] // .medium() will present half the screen
            sheet.prefersGrabberVisible = true // Optional: Show a grabber at the top of the sheet
            sheet.prefersEdgeAttachedInCompactHeight = true
            filterVC?.preferredContentSize = CGSize(width: self.view.frame.size.width, height: 500)
        }
        filterVC?.filterDelegate = self
    }
    
    private func setupNavigationBarItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem.logoBarButtonItem()
        let profileButton = UIBarButtonItem.profileBarButtonItem(target: self, action: #selector(showProfileVC))
        let notificationButton = UIBarButtonItem.notificationBarButtonItem(target: self, action: #selector(showNotificationsVC))
        navigationItem.rightBarButtonItems = [profileButton, notificationButton]
    }
    
    @objc func refreshList() {
        if (searchBar != nil), (viewModel != nil) {
            self.currentPage = 1
            searchBar.text = ""
            searchBar.resignFirstResponder()
            fetchTripsList()
        }
    }
    
    private func fetchTripsList() {
        LSProgress.show(in: self.view)
        Task {
            do {
                var parameters = ["page": String(currentPage), "limit": String(limit)]
               
                requestbody.searchByTripIdAndVehicleId = searchBar.text
                try await viewModel.fetchTrips(parameters: parameters, requestbody: requestbody)
                DispatchQueue.main.async {
                    self.tableView.delegate = self
                    self.tableView.dataSource = self
                    self.reloadTable()
                    self.refreshControl.endRefreshing()
                    LSProgress.hide(from: self.view)
                }
            } catch {
                UIAlertController.showError(on: self, error: error)
                self.refreshControl.endRefreshing()
                LSProgress.hide(from: self.view)
            }
        }
    }
    
    private func loadMoreTrips() {
        guard !isLoading else { return } // Prevent duplicate API calls
        isLoading = true

        loadingIndicator.startAnimating()

        Task {
            do {
                var parameters = ["page": String(currentPage), "limit": String(limit)]
                requestbody.searchByTripIdAndVehicleId = searchBar.text

                try await viewModel.loadMoreTrips(parameters: parameters, requestbody: requestbody)
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
    
    @IBAction func filterAction(_ sender: Any) {
        self.view.endEditing(true)

        if let filterVC = filterVC {
            present(filterVC, animated: true, completion: nil)
        }
    }
}

extension LSDTripsListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let tripsCount = viewModel.numberOfRows()
        if tripsCount > 0 {
            return tripsCount
        }
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tripsCount = viewModel.numberOfRows()
        if tripsCount > 0 {
            return self.tableView(tableView, tripsCellForRowAt: indexPath)
        }
        return self.tableView(tableView, noDataCellForRowAt: indexPath)

    }
    
    func tableView(_ tableView: UITableView, tripsCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LSDTripsListCell", for: indexPath) as? LSDTripsListCell else {
            return UITableViewCell()
        }

        let trip = viewModel.itemAt(indexPath:indexPath)
        cell.configure(with: trip, at: indexPath, in: tableView)
        return cell
    }
    
    func tableView(_ tableView: UITableView, noDataCellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let noDataFound = UILabel.init(frame: tableView.bounds)
        noDataFound.backgroundColor = .appBackground
        noDataFound.text = "No Data Available"
        noDataFound.textAlignment = .center
        noDataFound.textColor = .lightGray
        cell.addSubview(noDataFound)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        self.view.endEditing(true)
        let tripsCount = viewModel.numberOfRows()
        if tripsCount == 0 {
            return
        }
        let trip = viewModel.itemAt(indexPath: indexPath)
        if let isOrphaned = trip.isOrphaned, isOrphaned {
            self.view.makeToast("This is an Truncated trip", position: .bottom)
        } else {
            let tripDetailsContainerVC = LSTripDetailsContainerViewController.instantiate(fromStoryboard: .main)
            tripDetailsContainerVC.trip = trip
            self.navigationController?.pushViewController(tripDetailsContainerVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.numberOfRows() - 1 { // Last cell
            if let pageDetails = viewModel.pageDetails, viewModel.numberOfRows() < pageDetails.totalRecords, !isLoading {
                print("Number of Rows = ", viewModel.numberOfRows())
                print("totalRecords = ", pageDetails.totalRecords)
                print("Current Page = ", currentPage)

                currentPage += 1
                loadMoreTrips()
            }
        }
    }
    
}

extension LSDTripsListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        debounceTimer?.invalidate() // Invalidate any existing timer
        // Create a new debounce timer
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false) { [weak self] _ in
            self?.currentPage = 1
//            self?.requestbody = LSRequstTrips()
            self?.fetchTripsList()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
//        self.requestbody = LSRequstTrips()
        self.fetchTripsList()
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: LSTripsFilterDelegate
extension LSDTripsListViewController: LSTripsFilterDelegate {
    func didtapOnSearch(requestModel: LSRequstTrips) {
        self.view.endEditing(true)
        currentPage = 1
        self.requestbody = requestModel
        self.fetchTripsList()

    }
    
    func didtapOnClearFilter() {
        self.currentPage = 1
        self.requestbody = LSRequstTrips()
        self.fetchTripsList()
    }
    
}
