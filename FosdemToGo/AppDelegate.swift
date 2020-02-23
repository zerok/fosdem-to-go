//
//  AppDelegate.swift
//  fosdem-to-go
//
//  Created by Horst Gutmann on 21.01.20.
//  Copyright © 2020 Horst Gutmann. All rights reserved.
//

import UIKit
import CoreData
import FosdemSchedule
import ReSwift
import Network

struct AppState: StateType {
    var selectedYear : String?
    var availableYears : [String] = []
    var scheduleForYear: String? = nil
    var schedule: Schedule? = nil
    var scheduleDownloadLoading: Bool = false
    var scheduleDownloadFailed: Error? = nil
    var scheduleDownloadSucceeded: Bool? = nil
    var scheduleDownloadedTo: URL? = nil
    var networkStatus: NWPath?
    var bookmarkedEvents: BookmarksCollection? = nil
    
    init() {
        selectedYear = UserDefaults.standard.string(forKey: "selectedYear")
    }
}

func mainReducer(action: Action, state: AppState?) -> AppState {
    var state = state ?? AppState()
    if let action = action as? AppStateAction {
        switch action {
        case .loadAvailableYears:
            state.availableYears = (2012...2020).map({(year: Int) -> String in
                return String(year)
            })
            do {
                try ScheduleFileManager.shared.update()
            } catch {
                print("Failed to check for local files!")
            }
        case .selectYear(let year):
            state.selectedYear = year
            UserDefaults.standard.set(year, forKey: "selectedYear")
        case .updateSchedule(let schedule, forYear: let year):
            state.scheduleForYear = year
            state.schedule = schedule
            state.scheduleDownloadSucceeded = nil
            state.scheduleDownloadFailed = nil
            state.scheduleDownloadedTo = nil
            state.bookmarkedEvents = BookmarksCollection(year: year)
            state.bookmarkedEvents!.load()
        case .startScheduleDownload(year: _):
            state.scheduleDownloadLoading = true
            state.scheduleDownloadFailed = nil
            state.scheduleDownloadSucceeded = nil
            state.scheduleDownloadedTo = nil
        case .scheduleDownloadFailed(withError: let err):
            state.scheduleDownloadFailed = err
            state.scheduleDownloadSucceeded = false
            state.scheduleDownloadLoading = false
            state.scheduleDownloadedTo = nil
        case .scheduleDownloadSucceeded(url: let tmpURL):
            state.scheduleDownloadedTo = tmpURL
            state.scheduleDownloadLoading = false
            state.scheduleDownloadFailed = nil
            state.scheduleDownloadSucceeded = true
        case .addEventToBookmarks(id: let id):
            guard state.bookmarkedEvents != nil else { return state }
            state.bookmarkedEvents!.add(eventID: id)
            state.bookmarkedEvents!.save()
        case .removeEventFromBookmarks(id: let id):
            guard state.bookmarkedEvents != nil else { return state }
            state.bookmarkedEvents!.remove(eventID: id)
            state.bookmarkedEvents!.save()
        case .networkStatusChanged(path: let path):
            state.networkStatus = path
            print(path.status)
        }
    }
    return state
}

let mainStore = Store<AppState>(
    reducer: mainReducer,
    state: AppState()
)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, StoreSubscriber {
    func newState(state: AppState) {
        guard let nwStatus = state.networkStatus else { return }
        if state.scheduleForYear != state.selectedYear {
            print("Current year (\(state.scheduleForYear ?? "<no year>")) does not match selected year (\(state.selectedYear ?? "<no year>"))")
            if nwStatus.status == .unsatisfied {
                return
            }
            let year = state.selectedYear!
            let appSupportPath = "\(NSHomeDirectory())/Library/Application Support"
            let contentPath = "\(appSupportPath)/\(year).xml"
            do {
                try FileManager.default.createDirectory(atPath: appSupportPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                NSLog("Failed to create content directory: \(error)")
                return
            }
            let contentURL = URL(fileURLWithPath: contentPath)
            let downloadURL = URL(string: "https://fosdem.org/\(year)/schedule/xml")!
            let fileExists = FileManager.default.fileExists(atPath: contentPath)
            print("File exists? \(fileExists) Downloading? \(state.scheduleDownloadLoading) Failed? \(state.scheduleDownloadFailed) Succeeded? \(state.scheduleDownloadSucceeded)")
            if !fileExists && !state.scheduleDownloadLoading && state.scheduleDownloadFailed == nil && state.scheduleDownloadSucceeded  == nil {
                mainStore.dispatch(AppStateAction.startScheduleDownload(year: year))
                print("Starting download")
                let task = URLSession.shared.downloadTask(with: downloadURL, completionHandler: {(url,
                    response, error) in
                    print("Downloading \(downloadURL)")
                    if error != nil {
                        print("Download failed")
                        mainStore.dispatch(AppStateAction.scheduleDownloadFailed(withError: error!))
                        return
                    }
                    if let url = url {
                        print("Download succeeded")

                        mainStore.dispatch(AppStateAction.scheduleDownloadSucceeded(url: url))
                    }
                })
                task.resume()
                return
            }
            if !state.scheduleDownloadLoading && state.scheduleDownloadedTo != nil {
                // Now we move the file to it's final location:
                do {
                    print("Source exists? \(FileManager.default.fileExists(atPath: state.scheduleDownloadedTo!.path))")
                    if !FileManager.default.fileExists(atPath: state.scheduleDownloadedTo!.path) {
                        return
                    }
                    print("Moving \(state.scheduleDownloadedTo!.path) to \(contentPath)")
                    try FileManager.default.moveItem(atPath: state.scheduleDownloadedTo!.path, toPath: contentPath)
                    try ScheduleFileManager.shared.update()
                } catch {
                    print(error)
                    return
                }
            }
            
            if FileManager.default.fileExists(atPath: contentPath) {
                do {
                    let schedule = try FosdemSchedule.shared.loadFile(url: contentURL)
                    if let schedule = schedule {
                        print("Schedule updated")
                        mainStore.dispatch(AppStateAction.updateSchedule(schedule, forYear: year))
                    }
                } catch {
                    print(error)
                }
            }
        }
    }
    
    typealias StoreSubscriberStateType = AppState
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        startNetworkMonitor()
        mainStore.dispatch(AppStateAction.loadAvailableYears)
        mainStore.subscribe(self)
        mainStore.dispatch(AppStateAction.selectYear(mainStore.state.selectedYear ?? "2020"))
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func startNetworkMonitor() {
        let monitor = NWPathMonitor()
        mainStore.dispatch(AppStateAction.networkStatusChanged(path: monitor.currentPath))
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                mainStore.dispatch(AppStateAction.networkStatusChanged(path: path))
            }
            
        }
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }

}

