//
//  DayTrackViewController.swift
//  FosdemToGo
//
//  Created by Horst Gutmann on 08.02.20.
//  Copyright © 2020 Horst Gutmann. All rights reserved.
//

import Foundation
import UIKit
import FosdemSchedule

class DayTrackViewController: UITableViewController {
    var dayIdx: Int = -1
    var trackIdx: Int = -1
    var events: [Event] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let schedule = mainStore.state.schedule {
            events = schedule.days[self.dayIdx].getEvents(forTrack: self.title!)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "eventCell")!
        let evt = events[indexPath.row]
        cell.textLabel?.text = evt.title!
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.timeZone = TimeZone(identifier: "Europe/Brussels")
        if let time = evt.interval {
            cell.detailTextLabel?.text = formatter.string(from: time.start)
        }
        return cell
    }
}
