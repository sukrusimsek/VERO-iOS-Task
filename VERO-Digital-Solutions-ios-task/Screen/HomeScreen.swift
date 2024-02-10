//
//  ViewController.swift
//  VERO-Digital-Solutions-ios-task
//
//  Created by Şükrü Şimşek on 6.02.2024.
//

import UIKit
import Network
import Reachability

protocol HomeScreenInterface: AnyObject {
        func configureVC()
        func configureTableView()
        func configureSearchController()
        func fetchData()
        func saveToCoreData()
        func fetchFromCoreData()
        func networkConnected()
        func createRefresh()
    
}
final class HomeScreen: UIViewController {
    private let viewModel = HomeViewModel()
    private let tableView = UITableView()
    private var searchController = UISearchController()
    private var networkcheck = NWPathMonitor()
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
    @objc func qrButtonTapped() {
        print("QR Tapped")
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomCell
        let task = filteredInfo[indexPath.row]
        cell.cellSetup(task)
        return cell
    }

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
    func saveToCoreData() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        for info in allInfo {
            let entity = CoreDataModel(context: context)
            entity.title = info.title
            entity.task = info.task
            entity.desc = info.description
            entity.colorCode = info.colorCode
        }
        do {
            try context.save()
            print("Data saved CoreData")
        } catch {
            print("Found Error: \(error.localizedDescription)")
        }
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
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
            print("Error Fetch at CoreData: \(error)")
        }
        
    }
    func configureSearchController() {
        searchController.delegate = self
        navigationItem.titleView = searchController.searchBar
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        
    }
    func networkConnected() {
        let reachability = try! Reachability()
        if reachability.connection == .unavailable {  // offline
            if let savedData = try? fetchFromCoreData() {
                tableView.reloadData()
            }
        } else { // online
            print("Onlinee!!!")
        }

    }
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
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchController.searchBar.text = ""
        searchController.searchBar.endEditing(true)
        DispatchQueue.main.async {
            self.filteredInfo = self.allInfo
            self.tableView.reloadData()
            
        }
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        if searchText.count == 0 {
//            searchBar.searchTextField.resignFirstResponder()
//            tableView.reloadData()
//        }
    }
}
