//
//  UserScheduleController.swift
//  FosdemToGo
//
//  Created by Horst Gutmann on 21.02.20.
//  Copyright © 2020 Horst Gutmann. All rights reserved.
//

import Foundation
import UIKit
import ReSwift

class UserScheduleController: UINavigationController, StoreSubscriber {
    typealias StoreSubscriberStateType = AppState
    private var currentYear: String?
    
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
