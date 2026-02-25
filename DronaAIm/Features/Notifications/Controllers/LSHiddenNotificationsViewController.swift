//
//  LSHiddenNotificationsViewController.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 04/12/24.
//

import UIKit

class LSHiddenNotificationsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectButton: UIBarButtonItem!

    private let viewModel = LSDNotificationsViewModel()
    private var isEditingMode = false
    private var selectedItems = [LSNotification]()
    private lazy var bottomBar: UIToolbar = {
            let toolbar = UIToolbar()
            toolbar.isHidden = true
            return toolbar
        }()
    
    var page: Int = 1
    var limit = 2000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Hidden"
        setupTableView()
        setupBottomBar()
        loadNotifications()
        // Do any additional setup after loading the view.
    }
    
    private func loadNotifications() {
        performAsyncTask(
            task: { [weak self] in
                guard let self = self else {
                    throw NSError(domain: "LSHiddenNotificationsViewController", code: -1, userInfo: [NSLocalizedDescriptionKey: "ViewController deallocated"])
                }
                return try await self.viewModel.fetchNotifications(limit: String(self.limit))
            },
            onSuccess: { [weak self] _ in
                guard let self = self else { return }
                self.viewModel.showHiddenNotifications()
                self.tableView.delegate = self
                self.tableView.dataSource = self
                self.tableView.reloadData()
            }
        )
    }
    
    private func setupTableView() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80 // Estimate row height
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.register(LSLoadingCell.self, forCellReuseIdentifier: LSLoadingCell.identifier)
        tableView.register(NoDataCell.self, forCellReuseIdentifier: "cell")

      }
      
    private func setupBottomBar() {
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomBar)
        
        NSLayoutConstraint.activate([
            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            bottomBar.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    private func updateToolbarOptions() {
        let readAll = UIBarButtonItem(title: "Mark as Read All", style: .plain, target: self, action: #selector(markReadAll))
        let read = UIBarButtonItem(title: "Mark as Read", style: .plain, target: self, action: #selector(markAsRead))
        let unRead = UIBarButtonItem(title: "Mark as Unread", style: .plain, target: self, action: #selector(markAsUnRead))


        let unHide = UIBarButtonItem(title: "UnHide", style: .plain, target: self, action: #selector(markAsUnHide))

        
        let unHideAll = UIBarButtonItem(title: "UnHide All", style: .plain, target: self, action: #selector(markAsUnHideAll))


        let unReadItem = selectedItems.first(where: { $0.isRead == false})
        let readItem = selectedItems.first(where: { $0.isRead == true})

        let space = UIBarButtonItem.flexibleSpace()
       
        bottomBar.items = [readAll, space, unHideAll]
        
        if readItem != nil {
            bottomBar.items = [unRead, space, unHide]
        } else if unReadItem != nil {
            bottomBar.items = [read, space, unHide]
        }
//        else {
//            read.isEnabled = false
//            bottomBar.items = [read]
//        }
        if unReadItem != nil && readItem != nil {
            bottomBar.items = [read, space, unHide]
        }
    }
    
    @IBAction private func toggleEditingMode() {
         isEditingMode.toggle()
         tableView.setEditing(isEditingMode, animated: true)
         bottomBar.isHidden = !isEditingMode
         selectButton.title = isEditingMode ? "Done" : "Select"
        tabBarController?.tabBar.isHidden = isEditingMode
        
        let readAll = UIBarButtonItem(title: "Mark as Read All", style: .plain, target: self, action: #selector(markReadAll))

        let space = UIBarButtonItem.flexibleSpace()
        
        let unHideAll = UIBarButtonItem(title: "UnHide All", style: .plain, target: self, action: #selector(markAsUnHideAll))
     
        bottomBar.items = [readAll, space, unHideAll]
        if isEditingMode == false {
            selectedItems.removeAll()
        }

     }
    
    private func readApi(for notifications: [LSNotification], reloadToggle: Bool = true) {
        let messageIds = notifications.map({ $0.messageID }).compactMap({ $0 })
        Task {
            do {
                LSProgress.show(in: self.view)
                try await viewModel.readnotifications(for: messageIds)
                viewModel.markAsRead(for: messageIds)
                if reloadToggle {
                    toggleEditingMode()
                }
                viewModel.showHiddenNotifications()
                self.tableView.reloadData()
                LSProgress.hide(from: self.view)
                print("Success")
            } catch {
                print("Error = ", error.localizedDescription)
                LSProgress.hide(from: self.view)
            }
        }
    }
    
    private func unReadApi(for notifications: [LSNotification], reloadToggle: Bool = true) {
        let messageIds = notifications.map({ $0.messageID }).compactMap({ $0 })
        Task {
            do {
                LSProgress.show(in: self.view)
                try await viewModel.unReadnotifications(for: messageIds)
                viewModel.markAsUnRead(for: messageIds)
                if reloadToggle {
                    toggleEditingMode()
                }
                viewModel.showHiddenNotifications()
                self.tableView.reloadData()
                print("Success")
                LSProgress.hide(from: self.view)
            } catch {
                print("Error = ", error.localizedDescription)
                LSProgress.hide(from: self.view)
            }
        }
    }
    
    @objc private func markAsRead() {
        readApi(for: selectedItems)
    }
    
    @objc private func markAsUnRead() {
        unReadApi(for: selectedItems)
    }
    
    @objc private func markReadAll() {
        let notifications = viewModel.allNotifications()
        // Perform your "Mark as Read" action here
        readApi(for: notifications)
    }
    
    @objc private func markAsUnHide() {
        var hiddenIds = UserDefaults.standard.messageIds
        let messageIds = selectedItems.map({ $0.messageID }).compactMap({ $0 })
        // Remove messageIds that match hiddenIds
        hiddenIds = hiddenIds.filter { !messageIds.contains($0) }

        // Update UserDefaults with the modified hiddenIds
        UserDefaults.standard.messageIds = hiddenIds
        toggleEditingMode()
        viewModel.showHiddenNotifications()
        self.tableView.reloadData()
    }
        
    @objc private func markAsUnHideAll() {
        UserDefaults.standard.messageIds = []
        toggleEditingMode()
            viewModel.showHiddenNotifications()
        self.tableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let tripsCount = viewModel.numberOfRows()
        if tripsCount > 0 {
            selectButton.isEnabled = true
            return viewModel.numberOfRows()
        } else {
            selectButton.isEnabled = false
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tripsCount = viewModel.numberOfRows()
        if tripsCount > 0 {
            return self.tableView(tableView, notificationCellForRowAt: indexPath)
        }
        return self.tableView(tableView, noDataCellForRowAt: indexPath)

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
    
    func tableView(_ tableView: UITableView, notificationCellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.row == viewModel.numberOfRows() {
            guard let loadingCell = tableView.dequeueReusableCell(withIdentifier: LSLoadingCell.identifier, for: indexPath) as? LSLoadingCell else {
                return UITableViewCell()
            }
//            loadingCell.startLoading()
            return loadingCell
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LSDnotificationsTableViewCell", for: indexPath) as? LSDnotificationsTableViewCell else {
            return UITableViewCell()
        }

        let notification = viewModel.notification(at: indexPath.row)
        cell.configure(with: notification)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tripsCount = viewModel.numberOfRows()
        if tripsCount > 0 {
            let notification = viewModel.notification(at: indexPath.row)
            guard isEditingMode else {
                tableView.deselectRow(at: indexPath, animated: true)
                readApi(for: [notification], reloadToggle: false)
                let popoverContentVC = LSNotificationDetailsViewController.instantiate(fromStoryboard: .driver)
                popoverContentVC.delegate = self
                popoverContentVC.notificationModel = notification
                popoverContentVC.modalPresentationStyle = .overCurrentContext
                self.definesPresentationContext = true
                popoverContentVC.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
                present(popoverContentVC, animated: false, completion: nil)
                return
            }
            selectedItems.append(notification)
            updateToolbarOptions()
        }

    }
            
        func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
            guard isEditingMode else { return }
            let notification = viewModel.notification(at: indexPath.row)
            // Additional actions when a row is deselected
            if let index = selectedItems.firstIndex(where: {$0.messageID == notification.messageID}) {
                selectedItems.remove(at: index)
            }
            updateToolbarOptions()
        }
    
    // MARK: - UITableViewDelegate
      func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
          let tripsCount = viewModel.numberOfRows()
          if tripsCount > 0 {
              // Create the "Edit" action
              let notification = viewModel.notification(at: indexPath.row)
              let hiddenIds = UserDefaults.standard.messageIds
              let readAction = UIContextualAction(style: .normal, title: "Mark as Read") { _, _, completionHandler in
                  self.readApi(for: [notification], reloadToggle: false)
                  completionHandler(true) // Indicates that the action was performed
              }
              
              let unReadAction = UIContextualAction(style: .normal, title: "Mark as Unread") { _, _, completionHandler in
                  self.unReadApi(for: [notification], reloadToggle: false)
                  completionHandler(true) // Indicates that the action was performed
              }
              
              let hideAction = UIContextualAction(style: .normal, title: "Hide") { _, _, completionHandler in
                  if let messageId = notification.messageID {
                      var hiddenIds = UserDefaults.standard.messageIds
                      hiddenIds.append(messageId)
                      UserDefaults.standard.messageIds = hiddenIds
                      self.viewModel.showHiddenNotifications()
                      self.tableView.reloadData()
                  }
                  completionHandler(true) // Indicates that the action was performed
              }
              let unHideAction = UIContextualAction(style: .normal, title: "UnHide") { _, _, completionHandler in
                  if let messageId = notification.messageID {
                      var hiddenIds = UserDefaults.standard.messageIds
                      hiddenIds.removeAll { $0 == messageId }
                      UserDefaults.standard.messageIds = hiddenIds
                      self.viewModel.showHiddenNotifications()
                      self.tableView.reloadData()
                  }
                  completionHandler(true) // Indicates that the action was performed
              }
              readAction.backgroundColor = .systemBlue
              unReadAction.backgroundColor = .systemBlue
              
              var actions: [UIContextualAction] = []
              if notification.isRead ?? false {
                  actions.append(unReadAction)
              } else {
                  actions.append(readAction)
              }
              
              if let messageid = notification.messageID,  hiddenIds.contains(messageid) {
                  actions.append(unHideAction)
              } else {
                  actions.append(hideAction)
              }
              // Return the configuratio`n with the Edit action
              let configuration = UISwipeActionsConfiguration(actions: actions)
              configuration.performsFirstActionWithFullSwipe = false // Prevents full swipe for the action
              return configuration
          }
          return nil
      }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let tripsCount = viewModel.numberOfRows()
        if tripsCount == 0 {
            return tableView.frame.size.height
        }
        return UITableView.automaticDimension
    }
      
    
}

extension LSHiddenNotificationsViewController: LSNotificationDetailsDelegate {
    func didTapuploadButton() {
        let documentsVC = LSDocumentsViewController.instantiate(fromStoryboard: .driver)
        self.navigationController?.pushViewController(documentsVC, animated: true)
    }
}
