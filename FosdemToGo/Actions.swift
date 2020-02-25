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
import ReSwift_Thunk

enum AppStateAction: Action{
    case loadAvailableYears
    case selectYear(String)
    case updateSchedule(Schedule, forYear: String)
    case startScheduleDownload(year: String)
    case scheduleDownloadFailed(withError: Error)
    case updateScheduleFailed(withError: Error)
    case scheduleDownloadSucceeded(url: URL)
    case addEventToBookmarks(id: String)
    case removeEventFromBookmarks(id: String)
    case networkStatusChanged(path: NWPath)
    case startRefreshSchedule
}

func contentPathForYear(year: String) -> String {
    let appSupportPath = "\(NSHomeDirectory())/Library/Application Support"
    return "\(appSupportPath)/\(year).xml"
}

extension AppStateAction {
    static let refreshSchedule = Thunk<AppState> { dispatch, getState in
        dispatch(AppStateAction.startRefreshSchedule)
    }
    
    static let loadScheduleFromFile = Thunk<AppState> { dispatch, getState in
        guard let state = getState() else { return }
        guard let year = state.selectedYear else { return }
        do {
            let schedule = try FosdemSchedule.shared.load(fileAtPath: contentPathForYear(year: year))
            if let schedule = schedule {
                mainStore.dispatch(AppStateAction.updateSchedule(schedule, forYear: year))
            }
        } catch {
            mainStore.dispatch(AppStateAction.updateScheduleFailed(withError: error))
        }
    }
    
    static let downloadSchedule = Thunk<AppState> { dispatch, getState in
        guard let state = getState() else { return }
        guard let year = state.selectedYear else { return }
        guard !state.scheduleDownloadLoading else { return }
        dispatch(AppStateAction.startScheduleDownload(year: year))
        let appSupportPath = "\(NSHomeDirectory())/Library/Application Support"
        let contentPath = "\(appSupportPath)/\(year).xml"
        do {
            try FileManager.default.createDirectory(atPath: appSupportPath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            dispatch(AppStateAction.scheduleDownloadFailed(withError: error))
            return
        }
         let downloadURL = URL(string: "https://fosdem.org/\(year)/schedule/xml")!
//        let downloadURL = URL(string: "https://zerokspot.com/tmp/\(year).xml")!
        let task = URLSession.shared.downloadTask(with: downloadURL, completionHandler: {(url,
            response, error) in
            if error != nil {
                dispatch(AppStateAction.scheduleDownloadFailed(withError: error!))
                return
            }
            guard let resp = response as? HTTPURLResponse else {
                dispatch(AppStateAction.scheduleDownloadFailed(withError: error!))
                return
            }
            guard resp.statusCode == 200 else {
                dispatch(AppStateAction.scheduleDownloadFailed(withError: NSError(domain: "app", code: resp.statusCode)))
                return
            }
            if let url = url {
                do {
                    if FileManager.default.fileExists(atPath: contentPath) {
                        try FileManager.default.removeItem(atPath: contentPath)
                    }
                    try FileManager.default.moveItem(atPath: url.path, toPath: contentPath)
                    try ScheduleFileManager.shared.update()
                    dispatch(AppStateAction.loadScheduleFromFile)
                } catch {
                    dispatch(AppStateAction.scheduleDownloadFailed(withError: error))
                }
            }
        })
        task.resume()
    }
}
