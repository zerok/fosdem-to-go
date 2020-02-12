//
//  TalkDetailsViewController.swift
//  FosdemToGo
//
//  Created by Horst Gutmann on 12.02.20.
//  Copyright © 2020 Horst Gutmann. All rights reserved.
//

import Foundation
import UIKit
import FosdemSchedule
import WebKit

class TalkDetailsViewController: UIViewController {
    var event: Event?

    @IBOutlet var titleView: UILabel!
    
    @IBOutlet var abstractView: UILabel!
    
    @IBOutlet var roomNameView: UILabel!
    
    @IBOutlet var timeView: UILabel!
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let button = UIBarButtonItem()
        button.image = UIImage(systemName: "bookmark")
        button.title = "Bookmark"
        self.navigationItem.rightBarButtonItem = button
        self.navigationItem.largeTitleDisplayMode = .never
        guard let event = self.event else { return }
        self.titleView.text = event.title
        self.abstractView.text = event.abstract?.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        self.roomNameView.text = event.roomName
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .short
        if let interval = event.interval {
            let start = timeFormatter.string(from: interval.start)
            let end = timeFormatter.string(from: interval.end)
            self.timeView.text = "\(start) - \(end)"
        } else {
            self.timeView.text = "?"
        }
    }
}
