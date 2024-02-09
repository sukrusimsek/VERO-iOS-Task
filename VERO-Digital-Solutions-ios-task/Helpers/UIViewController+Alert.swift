//
//  UIViewController+Alert.swift
//  VERO-Digital-Solutions-ios-task
//
//  Created by Şükrü Şimşek on 8.02.2024.
//

import UIKit
extension UIViewController {
    func alert(message: String, title: String = "") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 ) {
            alertController.dismiss(animated: true)
        }
    }
}

