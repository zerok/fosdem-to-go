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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "talkCell")! as! EventTableCell
        guard indexPath.row < events.count else { return cell }
        guard let bookmarkedEvents = mainStore.state.bookmarkedEvents else { return cell }
        let evt = events[indexPath.row]
        guard evt.id != nil else { return cell }
        cell.from(event: evt)
        cell.tag = indexPath.row
        if bookmarkedEvents.contains(eventID: evt.id!) {
            cell.bookmark()
        }
        return cell
    }
        
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        self.tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let cell = sender as?  UITableViewCell else {
            print("Sender is not a cell but a \(sender)")
            return
        }
        guard let destination = segue.destination as? TalkDetailsViewController else {
            print("Unexpected destination \(segue.destination)")
            return
        }
        destination.event = self.events[cell.tag]
    }
}
