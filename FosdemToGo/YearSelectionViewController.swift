//
//  YearSelectionViewController.swift
//  FosdemToGo
//
//  Created by Horst Gutmann on 08.02.20.
//  Copyright © 2020 Horst Gutmann. All rights reserved.
//

import Foundation
import UIKit
import ReSwift

class YearSelectionViewController: UITableViewController, StoreSubscriber {
    func newState(state: AppState) {
        tableView.reloadData()
    }
    
    typealias StoreSubscriberStateType = AppState
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mainStore.state.availableYears.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let yearName = mainStore.state.availableYears[indexPath.row]
        let cell = ScheduleFileManager.shared.isAvailable(year: yearName) ? tableView.dequeueReusableCell(withIdentifier: "yearCell")!
            :
            tableView.dequeueReusableCell(withIdentifier: "disabledYearCell")!
        
        cell.textLabel?.text = yearName
        if yearName == mainStore.state.selectedYear {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let yearName = mainStore.state.availableYears[indexPath.row]
        mainStore.dispatch(AppStateAction.selectYear(yearName))
        self.navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        guard let nwStatus = mainStore.state.networkStatus else { return nil }
        let yearName = mainStore.state.availableYears[indexPath.row]
        if ScheduleFileManager.shared.isAvailable(year: yearName) {
            return indexPath
        }
        
        if nwStatus.status == .unsatisfied {
            OfflineModeAlert.shared.show(viewController: self)
            return nil
        }
        return indexPath
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mainStore.subscribe(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mainStore.unsubscribe(self)
    }
}
