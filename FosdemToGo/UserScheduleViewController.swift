//
//  UserScheduleViewController.swift
//  FosdemToGo
//
//  Created by Horst Gutmann on 15.02.20.
//  Copyright © 2020 Horst Gutmann. All rights reserved.
//

import Foundation
import UIKit
import ReSwift
import FosdemSchedule

class UserScheduleViewController: UITableViewController, StoreSubscriber {
    typealias StoreSubscriberStateType = AppState
    var bookmarks: [String] = []
    var events: [Event] = []
    var days: [String] = []
    var eventsPerDay: Dictionary<String, [Event]> = Dictionary<String, [Event]>()
    
    func newState(state: AppState) {
        guard let schedule = state.schedule else { return }
        days = []
        eventsPerDay = Dictionary<String, [Event]>()
        bookmarks = state.bookmarkedEvents.sorted().filter({ (id: String) in
            let elems = id.split(separator: ":")
            if elems.count < 2 {
                return false
            }
            if elems[0] != state.selectedYear ?? "" {
                return false
            }
            return true
        }).map({ (id: String) in
            return String(id.split(separator: ":")[1])
        })
        events = bookmarks.map({ (id: String) in
            return schedule.event(forId: id)!
        }).sorted(by: {
            if let i1 = $0.interval, let i2 = $1.interval {
                return i1.start < i2.start
            }
            return false
        })
        let df = DateFormatter()
        df.timeStyle = .none
        df.dateStyle = .medium
        var uniqueDates: Set<String> = Set<String>()
        for evt in events {
            let d = df.string(from: evt.interval!.start)
            if !uniqueDates.contains(d) {
                days.append(d)
                uniqueDates.insert(d)
                eventsPerDay[d] = []
            }
            eventsPerDay[d]?.append(evt)
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mainStore.subscribe(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mainStore.unsubscribe(self)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.days.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.days[section]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let idx = self.days[section]
        return (self.eventsPerDay[idx] ?? []).count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "talkCell")! as! EventTableCell
        let idx = self.days[indexPath.section]
        let event = eventsPerDay[idx]![indexPath.row]
        cell.from(event: event)
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let cell = sender as?  EventTableCell else {
            print("Sender is not a cell but a \(sender)")
            return
        }
        guard let destination = segue.destination as? TalkDetailsViewController else {
            print("Unexpected destination \(segue.destination)")
            return
        }
        destination.event = cell.event
    }
}
