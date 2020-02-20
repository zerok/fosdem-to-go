//
//  YearViewController.swift
//  FosdemToGo
//
//  Created by Horst Gutmann on 06.02.20.
//  Copyright © 2020 Horst Gutmann. All rights reserved.
//

import Foundation
import UIKit
import FosdemSchedule
import ReSwift

class YearViewController: UITableViewController, StoreSubscriber {
    typealias StoreSubscriberStateType = AppState
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.title = mainStore.state.selectedYear ?? "no year selected"
    }
    
    func newState(state: AppState) {
        DispatchQueue.main.async {
            if state.scheduleDownloadLoading {
                LoadingIndicator.shared.show(viewController: self)
                return
            }
            if !state.scheduleDownloadLoading || state.schedule != nil {
                LoadingIndicator.shared.hide()
            }
            self.title = state.selectedYear
            self.tableView.reloadData()
        }
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
        if let schedule = self.schedule {
            return schedule.days.count
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "day")!
        if let schedule = self.schedule {
            cell.textLabel?.text = schedule.days[indexPath.row].description
        }
        cell.tag = indexPath.row
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell {
            let dayIdx = cell.tag
            let dvc = segue.destination as! DayViewController
            if let schedule = schedule {
                dvc.title = schedule.days[dayIdx].description
            }
            dvc.dayIdx = dayIdx
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mainStore.subscribe(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        mainStore.unsubscribe(self)
    }
}
