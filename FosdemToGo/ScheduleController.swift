//
//  ScheduleController.swift
//  FosdemToGo
//
//  Created by Horst Gutmann on 06.02.20.
//  Copyright © 2020 Horst Gutmann. All rights reserved.
//

import Foundation
import UIKit
import ReSwift

class ScheduleViewController: UINavigationController, StoreSubscriber {
    typealias StoreSubscriberStateType = AppState
    
    private var currentYear: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.prefersLargeTitles = true
    }
    
    func newState(state: AppState) {
        if state.selectedYear != currentYear {
            self.popToRootViewController(animated: true)
        }
        self.currentYear = state.selectedYear
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
