//
//  LoadingIndicator.swift
//  FosdemToGo
//
//  Created by Horst Gutmann on 20.02.20.
//  Copyright © 2020 Horst Gutmann. All rights reserved.
//

import Foundation
import UIKit

public class LoadingIndicator {
    private var alertCtrl: UIAlertController?
    public static let shared = LoadingIndicator()
    
    private init() {}
    
    public func show(viewController: UIViewController) {
        guard self.alertCtrl == nil else { return }
        print("Showing alert")
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        let indicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        indicator.startAnimating()
        indicator.style = .large
        alert.view.addSubview(indicator)
        self.alertCtrl = alert
        viewController.present(alert, animated: false, completion: nil)
    }
    
    public func hide() {
        guard let alertCtrl = self.alertCtrl else { return }
        alertCtrl.dismiss(animated: false, completion: nil)
        self.alertCtrl = nil
    }
}
