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

class SettingsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, StoreSubscriber {
    
    typealias StoreSubscriberStateType = AppState
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var yearPicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        yearPicker.delegate = self
        yearPicker.dataSource = self
    }
    
    func newState(state: AppState) {
        activityIndicator.startAnimating()
        if let selectedYear = state.selectedYear {
            if let idx = mainStore.state.availableYears.firstIndex(of: selectedYear) {
                yearPicker.selectRow(idx, inComponent: 0, animated: false)
            }
        }
        activityIndicator.stopAnimating()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return mainStore.state.availableYears[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return mainStore.state.availableYears.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        mainStore.dispatch(AppStateAction.selectYear(mainStore.state.availableYears[row]))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mainStore.subscribe(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        mainStore.unsubscribe(self)
    }
}
