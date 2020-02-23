//
//  Actions.swift
//  FosdemToGo
//
//  Created by Horst Gutmann on 07.02.20.
//  Copyright © 2020 Horst Gutmann. All rights reserved.
//

import Foundation
import ReSwift
import FosdemSchedule
import Network

enum AppStateAction: Action{
    case loadAvailableYears
    case selectYear(String)
    case updateSchedule(Schedule, forYear: String)
    case startScheduleDownload(year: String)
    case scheduleDownloadFailed(withError: Error)
    case scheduleDownloadSucceeded(url: URL)
    case addEventToBookmarks(id: String)
    case removeEventFromBookmarks(id: String)
    case networkStatusChanged(path: NWPath)
}
