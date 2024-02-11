//
//  HomeViewModel.swift
//  VERO-Digital-Solutions-ios-task
//
//  Created by Şükrü Şimşek on 7.02.2024.
//

import Foundation
protocol HomeViewModelInterface {
    var view: HomeScreenInterface? { get set }
    func viewDidLoad()
}

final class HomeViewModel {
    weak var view: HomeScreenInterface?
}

extension HomeViewModel: HomeViewModelInterface {
    func viewDidLoad() {
        view?.configureVC()
        view?.fetchData()
        view?.configureSearchController()
        view?.configureTableView()
        view?.networkConnected()
        view?.createRefresh()
        view?.addObserverForQR()
    }
    
}
