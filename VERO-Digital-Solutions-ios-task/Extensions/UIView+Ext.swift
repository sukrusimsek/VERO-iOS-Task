//
//  UIView+Ext.swift
//  VERO-Digital-Solutions-ios-task
//
//  Created by Şükrü Şimşek on 7.02.2024.
//

import UIKit

extension UIView {
    func pinToEdgesOf(view: UIView) {
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: view.topAnchor),
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
        ])
    }
}
