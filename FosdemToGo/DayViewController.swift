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
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.schedule!.days[self.dayIdx].description
    }
    
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
        return cell
    }
}
