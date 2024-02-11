//
//  QRViewModel.swift
//  VERO-Digital-Solutions-ios-task
//
//  Created by Şükrü Şimşek on 10.02.2024.
//

import Foundation
protocol QRViewModelInterface {
    var view: QRViewInterface? { get set }
    func viewDidLoad()
}

final class QRViewModel {
    weak var view: QRViewInterface?
    
}

extension QRViewModel: QRViewModelInterface {
    func viewDidLoad() {
        view?.configureVC()
        view?.configureInputData()
        view?.configureQROutputData()
        view?.configurePreviewLayer()
        
    }
}
