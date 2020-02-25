//
//  AboutViewController.swift
//  FosdemToGo
//
//  Created by Horst Gutmann on 23.02.20.
//  Copyright © 2020 Horst Gutmann. All rights reserved.
//

import Foundation
import UIKit

class AboutViewController: UIViewController {
    @IBOutlet var textView: UITextView!
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        viewDidLoad()
    }
    
    override func viewDidLoad() {
        let fgColor = UIScreen.main.traitCollection.userInterfaceStyle == .dark ? UIColor.white : UIColor.black
        let msg: NSMutableAttributedString = NSMutableAttributedString()
        let font = UIFont.systemFont(ofSize: 16)
        msg.append(NSAttributedString(string: "You can find the complete source code on ", attributes: [.font: font, .foregroundColor: fgColor]))
        msg.append(NSAttributedString(string: "Github", attributes: [.font: font, .foregroundColor: UIColor.white, .link: "https://github.com/zerok/fosdem-to-go"]))
        msg.append(NSAttributedString(string: ". Under the hood, the following libraries are used:\n\n - ", attributes: [.font: font, .foregroundColor: fgColor]))
        msg.append(NSAttributedString(string: "ReSwift", attributes: [.font: font, .foregroundColor: UIColor.white, .link: "https://github.com/ReSwift/ReSwift"]))
        msg.append(NSAttributedString(string: "\n\nAll session information is taken from ", attributes: [.font: font, .foregroundColor: fgColor]))
        msg.append(NSAttributedString(string: "FOSDEM.org", attributes: [.font: font, .foregroundColor: UIColor.white, .link: "https://fosdem.org"]))
        msg.append(NSAttributedString(string: ".", attributes: [.font: font, .foregroundColor: fgColor]))
        textView.attributedText = msg
    }
}
