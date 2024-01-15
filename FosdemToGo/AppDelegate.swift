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
import ReSwiftThunk
import Network

struct AppState: StateType {
    var selectedYear : String?
    var availableYears : [String] = []
    var scheduleForYear: String? = nil
    var schedule: Schedule? = nil
    var scheduleDownloadLoading: Bool = false
    var scheduleDownloadFailed: Error? = nil
    var updateScheduleFailed: Error? = nil
    var scheduleDownloadSucceeded: Bool? = nil
    var scheduleDownloadedTo: URL? = nil
    var networkStatus: NWPath?
    var bookmarkedEvents: BookmarksCollection? = nil
    var refreshSchedulePending: Bool = false
    
    init() {
        selectedYear = UserDefaults.standard.string(forKey: "selectedYear")
    }
}

func mainReducer(action: Action, state: AppState?) -> AppState {
    var state = state ?? AppState()
    if let action = action as? AppStateAction {
        switch action {
        case .loadAvailableYears:
            state.availableYears = (2012...2024).map({(year: Int) -> String in
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
            state.updateScheduleFailed = nil
        case .updateSchedule(let schedule, forYear: let year):
            state.scheduleForYear = year
            state.schedule = schedule
            state.scheduleDownloadLoading = false
            state.scheduleDownloadSucceeded = nil
            state.scheduleDownloadFailed = nil
            state.scheduleDownloadedTo = nil
            state.bookmarkedEvents = BookmarksCollection(year: year)
            state.bookmarkedEvents!.load()
            state.refreshSchedulePending = false
            state.updateScheduleFailed = nil
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
        case .startRefreshSchedule:
            state.refreshSchedulePending = true
        case .updateScheduleFailed(withError: let err):
            state.updateScheduleFailed = err
        }
    }
    return state
}

let thunkMiddleware: Middleware<AppState> = createThunkMiddleware()

let mainStore = Store<AppState>(
    reducer: mainReducer,
    state: AppState(),
    middleware: [thunkMiddleware]
)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, StoreSubscriber {
    func newState(state: AppState) {
        guard let year = state.selectedYear else { return }
        guard let nwStatus = state.networkStatus else { return }
        guard nwStatus.status == .satisfied else { return }
        guard !state.scheduleDownloadLoading && state.updateScheduleFailed == nil else { return }
        if state.scheduleForYear != year {
            let contentPath  = contentPathForYear(year: year)
            if FileManager.default.fileExists(atPath: contentPath) {
                mainStore.dispatch(AppStateAction.loadScheduleFromFile)
            } else {
                mainStore.dispatch(AppStateAction.downloadSchedule)
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

