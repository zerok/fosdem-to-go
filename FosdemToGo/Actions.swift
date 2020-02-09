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

enum AppStateAction: Action{
    case loadAvailableYears
    case selectYear(String)
    case updateSchedule(Schedule, forYear: String)
    case startScheduleDownload(year: String)
    case scheduleDownloadFailed(withError: Error)
    case scheduleDownloadSucceeded(url: URL)
}
