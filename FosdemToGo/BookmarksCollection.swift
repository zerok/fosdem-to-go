//
//  BookmarksCollection.swift
//  FosdemToGo
//
//  Created by Horst Gutmann on 23.02.20.
//  Copyright © 2020 Horst Gutmann. All rights reserved.
//

import Foundation

class BookmarksCollection {
    private var bookmarkedEvents = Set<String>()
    
    init() {}
    
    public func add(year: String, eventID: String) {
        let id = "\(year):\(eventID)"
        self.bookmarkedEvents.insert(id)
    }
    
    public func remove(year: String, eventID: String) {
        let id = "\(year):\(eventID)"
        self.bookmarkedEvents.remove(id)
    }
    
    public func contains(year: String, eventID: String) -> Bool {
        let id = "\(year):\(eventID)"
        return self.bookmarkedEvents.contains(id)
    }
    
    public func getEvents(year: String) -> [String] {
        return self.bookmarkedEvents.sorted().filter({ (id: String) in
            let elems = id.split(separator: ":")
            if elems.count < 2 {
                return false
            }
            if elems[0] != year {
                return false
            }
            return true
        }).map({ (id: String) in
            return String(id.split(separator: ":")[1])
        })
    }
    
    public func save() {
        UserDefaults.standard.set(self.bookmarkedEvents.sorted(), forKey: "bookmarks")
    }
    
    public func load() {
        if let bm = UserDefaults.standard.object(forKey: "bookmarks") {
            let bookmarks = bm as! [String]
            self.bookmarkedEvents = self.bookmarkedEvents.union(bookmarks)
        }
    }
}
