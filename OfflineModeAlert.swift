//
//  OfflineModeAlert.swift
//  FosdemToGo
//
//  Created by Horst Gutmann on 20.02.20.
//  Copyright © 2020 Horst Gutmann. All rights reserved.
//

import Foundation
import UIKit

public class OfflineModeAlert {
    private var alertCtrl: UIAlertController?
    public static let shared = OfflineModeAlert()
    
    private init() {}
    
    public func show(viewController: UIViewController) {
        guard self.alertCtrl == nil else { return }
        let alert = UIAlertController(title: "Offline", message: "You are currently offline and the selected year is not yet available offline.", preferredStyle: .alert)
        self.alertCtrl = alert
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            OfflineModeAlert.shared.hide()
        }))
        if !(viewController is YearSelectionViewController) {
            alert.addAction(UIAlertAction(title: "Pick different year", style: .default, handler: { action in
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let ctrl = storyBoard.instantiateViewController(identifier: "settings.yearselection")
                viewController.navigationController?.pushViewController(ctrl, animated: true)
            }))
        }
        viewController.present(alert, animated: false, completion: nil)
    }
    
    public func hide() {
        guard let alertCtrl = self.alertCtrl else { return }
        alertCtrl.dismiss(animated: false, completion: nil)
        self.alertCtrl = nil
    }
}
