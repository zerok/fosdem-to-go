//
//  EventTableCell.swift
//  FosdemToGo
//
//  Created by Horst Gutmann on 15.02.20.
//  Copyright © 2020 Horst Gutmann. All rights reserved.
//

import Foundation
import UIKit
import FosdemSchedule

class EventTableCell: UITableViewCell {
    @IBOutlet var locationLabel: UILabel?
    
    @IBOutlet var titleLabel: UILabel?
    
    @IBOutlet var timeLabel: UILabel?
    
    var event: Event?
    
    func bookmark() {
        if let textLabel = titleLabel {
            textLabel.textColor = UIColor.FOSDEM.bookmarking
        }
    }
    
    func from(event: Event) {
        let fgColor = UIScreen.main.traitCollection.userInterfaceStyle == .dark ? UIColor.white : UIColor.black
        self.event = event
        if let textLabel = titleLabel {
            textLabel.text = event.title
            textLabel.textColor = fgColor
        }
        if let locationLabel = locationLabel {
            locationLabel.text = event.roomName
        }
        if let detailLabel = timeLabel {
            let formatter = DateFormatter()
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            formatter.timeZone = TimeZone(identifier: "Europe/Brussels")
            if let time = event.interval {
                detailLabel.text = "\(formatter.string(from: time.start)) - \(formatter.string(from: time.end))"
            }
        }
    }
}
