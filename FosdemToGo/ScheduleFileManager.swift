//
//  ScheduleFileManager.swift
//  FosdemToGo
//
//  Created by Horst Gutmann on 21.02.20.
//  Copyright © 2020 Horst Gutmann. All rights reserved.
//

import Foundation

class ScheduleFileManager {
    public static let shared: ScheduleFileManager = ScheduleFileManager()
    private let appSupportPath = "\(NSHomeDirectory())/Library/Application Support"
    private var availableSchedules = Set<String>()
    
    private init() {
        
    }
    
    public func update() throws {
        let files = try FileManager.default.contentsOfDirectory(atPath: appSupportPath)
        for file in files {
            let filename = (file as NSString).lastPathComponent
            if filename.hasSuffix(".xml") {
                availableSchedules.insert(String(filename.split(separator: ".")[0]))
            }
        }
    }
    
    public func isAvailable(year: String) -> Bool {
        return self.availableSchedules.contains(year)
    }
}
