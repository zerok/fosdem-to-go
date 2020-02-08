//
//  UserSettings.swift
//  FosdemToGo
//
//  Created by Horst Gutmann on 06.02.20.
//  Copyright © 2020 Horst Gutmann. All rights reserved.
//

import Foundation

class UserSettings {
    static public let sharedInstance = UserSettings()
    
    var selectedYear: String {
        get {
            UserDefaults.standard.string(forKey: "selectedYear") ?? "2020"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "selectedYear")
            NotificationCenter.default.post(name: NSNotification.Name("settingsUpdated"), object: self)
        }
    }
    
    private init() {
        
    }
}
