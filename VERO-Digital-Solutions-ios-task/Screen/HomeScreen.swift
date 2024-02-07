//
//  ViewController.swift
//  VERO-Digital-Solutions-ios-task
//
//  Created by Şükrü Şimşek on 6.02.2024.
//

import UIKit

protocol HomeScreenInterface: AnyObject {
        func configureVC()
        func configureTableView()
        func configureSearchController()
}
final class HomeScreen: UIViewController {
    private let viewModel = HomeViewModel()
    var tableView = UITableView()
    var searchController = UISearchController()
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.view = self
        viewModel.viewDidLoad()
    }


}


extension HomeScreen: HomeScreenInterface , UITableViewDelegate, UITableViewDataSource{
    func configureVC() {
        title = "VERO"
        
    }
    func configureTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = view.frame.height/5
        tableView.backgroundColor = .blue
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UITableViewCell
        
        return cell
    }
    func configureSearchController() {
        searchController.searchBar.translatesAutoresizingMaskIntoConstraints = false
        
    }
}
