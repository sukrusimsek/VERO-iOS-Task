//
//  ViewController.swift
//  VERO-Digital-Solutions-ios-task
//
//  Created by Şükrü Şimşek on 6.02.2024.
//

import UIKit
import Reachability
import CoreData
import AVFoundation

protocol HomeScreenInterface: AnyObject {
        func configureVC()
        func configureTableView()
        func configureSearchController()
        func fetchData()
        func saveToCoreData()
        func fetchFromCoreData()
        func networkConnected()
        func createRefresh()
        func refreshCoreData()
        func addObserverForQR()
    
}
final class HomeScreen: UIViewController {
    private let viewModel = HomeViewModel()
    private let tableView = UITableView()
    private var searchController = UISearchController()
    private var refrestControl = UIRefreshControl()
    var allInfo = [Model]()
    var filteredInfo = [Model]()
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.view = self
        viewModel.viewDidLoad()
        
    }
    
}
extension HomeScreen: HomeScreenInterface , UITableViewDelegate, UITableViewDataSource {
    func configureVC() {
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "qrcode.viewfinder"), style: .plain, target: self, action: #selector(qrButtonTapped))
    }
    //Control for is this simulator or real device?
    @objc func qrButtonTapped() {
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            let vc = QRView()
            vc.modalPresentationStyle = .formSheet
            present(vc, animated: true)
            print("QR Tapped")
        } else {
            alert(message: "Your device is not supported to process scanning",title: "QR Error")
        }
    }
    
    func configureTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.estimatedRowHeight = 180
        self.tableView.rowHeight = UITableView.automaticDimension
        tableView.register(CustomCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)
        tableView.pinToEdgesOf(view: view)
        
    }
    // TableView funcs.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomCell
        let task = filteredInfo[indexPath.row]
        cell.cellSetup(task)
        return cell
    }
    //Fetch Data every online the connection.
    func fetchData(){
        NetworkManager.shared.authenticateUser { accessToken in
            guard let accessToken = accessToken else { return }
            NetworkManager.shared.fetchTasks(accessToken: accessToken) { tasks in
                guard let tasks = tasks else { return }
                self.allInfo = tasks
                self.filteredInfo = tasks
                
                DispatchQueue.main.async {
                    self.saveToCoreData()
                    self.tableView.reloadData()
                }
            }
        }
    }
    //Save To CoreData when online the connection.
    func saveToCoreData() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        refreshCoreData()
        for info in allInfo {
            let entity = CoreDataModel(context: context)
            entity.title = info.title
            entity.task = info.task
            entity.desc = info.description
            entity.colorCode = info.colorCode
        }
        do {
            try context.save()
            print("Data saved to CoreData")
        } catch {
            print("Error Found data didn't saved in core data: \(error.localizedDescription)")
        }
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    //Refresh CoreData every when online the connection.
    func refreshCoreData() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "CoreDataModel")
        do {
            let records = try context.fetch(fetchRequest)
            for case let record as NSManagedObject in records {
                context.delete(record)
                print("Delete coredata for new saved datas.")
            }
            try context.save()
        } catch {
            print("Error Found didn't delete the ex datas in core data: \(error.localizedDescription)")
        }
    }
    //Fetch Data from CoreData
    func fetchFromCoreData() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            allInfo = try context.fetch(CoreDataModel.fetchRequest()).map {
                Model(title: $0.title ?? "", task: $0.task ?? "", description: $0.desc ?? "", colorCode: $0.colorCode ?? "")
            }
            filteredInfo = allInfo
            tableView.reloadData()
            print("Data fetched from CoreData")
        } catch {
            print("Error Fetch at CoreData: \(error.localizedDescription)")
        }
        
    }
    func configureSearchController() {
        searchController.delegate = self
        navigationItem.titleView = searchController.searchBar
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        
    }
    //Connection control and coredata usage control depending on the situation.
    func networkConnected() {
        let reachability = try! Reachability()
        if reachability.connection == .unavailable { 
            allInfo.removeAll()
            fetchFromCoreData()
            print("Network Offline")
        } else {
            print("Network Online")
        }

    }
    //This is what will happen when we renovate.
    func createRefresh() {
        refrestControl.attributedTitle = NSAttributedString(string: "Pull to Refresh")
        refrestControl.addTarget(self, action: #selector(activeRefresh), for: .valueChanged)
        tableView.refreshControl = refrestControl
    }
    @objc func activeRefresh(refreshControl: UIRefreshControl) {
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            self.filteredInfo = self.allInfo
            self.tableView.reloadData()
            self.refrestControl.endRefreshing()
        }
    }
    
    
}
//Functions we need to use Search Bar
extension HomeScreen: UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text, text != "" else { return }
        
        filteredInfo = allInfo.filter({ task in
            let title =  task.title.lowercased().contains(text.lowercased())
            let task = task.task.lowercased().contains(text.lowercased())
            let description = task.description.lowercased().contains(text.lowercased())
            return title || task || description
        })
        tableView.reloadData()
    }
    //What we want to happen when we tap Cancel.
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchController.searchBar.text = ""
        searchController.searchBar.endEditing(true)
    }
    //Data from QRScanner for use in searchbar
    func addObserverForQR() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleQR), name: .QRName, object: nil)

    }
    //List the results according to the incoming QR result
    @objc func handleQR(_ notification: Notification) {
        guard let name = notification.object as? String else { return }
        searchController.searchBar.text = name
        filteredInfo = allInfo.filter({ task in
            let title =  task.title.lowercased().contains(name.lowercased())
            let task = task.task.lowercased().contains(name.lowercased())
            let description = task.description.lowercased().contains(name.lowercased())
            return title || task || description
        })
        tableView.reloadData()
        
    }

}
