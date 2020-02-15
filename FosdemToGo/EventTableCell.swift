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
    
    var event: Event?
    
    func from(event: Event) {
        self.event = event
        if let textLabel = textLabel {
            textLabel.text = event.title
        }
        if let locationLabel = locationLabel {
            locationLabel.text = event.roomName
        }
        if let detailLabel = detailTextLabel {
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
