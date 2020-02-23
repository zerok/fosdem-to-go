//
//  SettingsViewController.swift
//  FosdemToGo
//
//  Created by Horst Gutmann on 06.02.20.
//  Copyright © 2020 Horst Gutmann. All rights reserved.
//

import Foundation
import UIKit
import ReSwift

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, StoreSubscriber {
    typealias StoreSubscriberStateType = AppState
    
    @IBOutlet var tableView: UITableView!
            
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "item")!
            cell.textLabel?.text = "Year"
            cell.detailTextLabel?.text = mainStore.state.selectedYear ?? "..."
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "about")!
            cell.textLabel?.text = "About"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            self.performSegue(withIdentifier: "pickYear", sender: nil)
        } else {
            self.performSegue(withIdentifier: "showAbout", sender: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "General"
        } else {
            return "Info"
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    func newState(state: AppState) {
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
}
