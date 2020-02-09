//
//  DayViewController.swift
//  FosdemToGo
//
//  Created by Horst Gutmann on 07.02.20.
//  Copyright © 2020 Horst Gutmann. All rights reserved.
//

import Foundation
import UIKit
import FosdemSchedule

class DayViewController: UITableViewController {
    var dayIdx: Int = 0

    var schedule: Schedule? {
        get {
            return mainStore.state.schedule
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.schedule!.days[self.dayIdx].rooms.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "room")!
        cell.textLabel?.text = self.schedule!.days[self.dayIdx].tracks[indexPath.row]
        cell.tag = indexPath.row
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell {
            let destination = segue.destination as! DayTrackViewController
            if let cell = sender as? UITableViewCell {
                destination.title = cell.textLabel?.text
            }
            destination.dayIdx = self.dayIdx
            destination.trackIdx = cell.tag
        }
    }
}
