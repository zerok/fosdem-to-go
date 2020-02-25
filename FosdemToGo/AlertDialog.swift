//
//  AlertDialog.swift
//  FosdemToGo
//
//  Created by Horst Gutmann on 20.02.20.
//  Copyright © 2020 Horst Gutmann. All rights reserved.
//

import Foundation
import UIKit

public class AlertDialog {
    private var alertCtrl: UIAlertController?
    public static let shared = AlertDialog()
    
    private init() {}
    
    public func show(viewController: UIViewController, msg: String) {
        guard self.alertCtrl == nil else { return }
        let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            AlertDialog.shared.hide()
        }))
        self.alertCtrl = alert
        viewController.present(alert, animated: false, completion: nil)
    }
    
    public func hide() {
        guard let alertCtrl = self.alertCtrl else { return }
        alertCtrl.dismiss(animated: false, completion: nil)
        self.alertCtrl = nil
    }
}
