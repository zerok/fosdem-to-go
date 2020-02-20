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

struct AppState: StateType {
    var selectedYear : String?
    var availableYears : [String] = []
    var scheduleForYear: String? = nil
    var schedule: Schedule? = nil
    var scheduleDownloadLoading: Bool = false
    var scheduleDownloadFailed: Error? = nil
    var scheduleDownloadSucceeded: Bool? = nil
    var scheduleDownloadedTo: URL? = nil
    var bookmarkedEvents: Set<String> = Set<String>()
    
    init() {
        selectedYear = UserDefaults.standard.string(forKey: "selectedYear")
        if let bm = UserDefaults.standard.object(forKey: "bookmarks") {
            let bookmarks = bm as! [String]
            self.bookmarkedEvents = self.bookmarkedEvents.union(bookmarks)
        }
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
        case .selectYear(let year):
            state.selectedYear = year
            UserDefaults.standard.set(year, forKey: "selectedYear")
        case .updateSchedule(let schedule, forYear: let year):
            state.scheduleForYear = year
            state.schedule = schedule
            state.scheduleDownloadSucceeded = nil
            state.scheduleDownloadFailed = nil
            state.scheduleDownloadedTo = nil
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
        case .addEventToBookmarks(year: let year, id: let id):
            let fullID = "\(year):\(id)"
            state.bookmarkedEvents.insert(fullID)
            UserDefaults.standard.set(state.bookmarkedEvents.sorted(), forKey: "bookmarks")
        case .removeEventFromBookmarks(year: let year, id: let id):
            let fullID = "\(year):\(id)"
            state.bookmarkedEvents.remove(fullID)
            UserDefaults.standard.set(state.bookmarkedEvents.sorted(), forKey: "bookmarks")
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
        if state.scheduleForYear != state.selectedYear {
            print("Current year (\(state.scheduleForYear)) does not match selected year (\(state.selectedYear))")
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

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "FosdemToGo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                NSLog("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        NSLog("Saving context")
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

