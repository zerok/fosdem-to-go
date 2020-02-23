//
//  BookmarksCollection.swift
//  FosdemToGo
//
//  Created by Horst Gutmann on 23.02.20.
//  Copyright © 2020 Horst Gutmann. All rights reserved.
//
import Foundation

public class BookmarksCollection {
    private var bookmarkedEvents = Set<String>()
    private var year: String?
    
    public init(year: String) {
        self.year = year
    }
    
    public func add(eventID: String) {
        guard let year = self.year else { return }
        let id = "\(year):\(eventID)"
        self.bookmarkedEvents.insert(id)
    }
    
    public func remove(eventID: String) {
        guard let year = self.year else { return }
        let id = "\(year):\(eventID)"
        self.bookmarkedEvents.remove(id)
    }
    
    public func contains(eventID: String) -> Bool {
        guard let year = self.year else { return false }
        let id = "\(year):\(eventID)"
        return self.bookmarkedEvents.contains(id)
    }
    
    public func getEvents() -> [String] {
        guard let year = self.year else { return [] }
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
    
    public func save(to userdefaults: UserDefaults) {
        guard let year = year else { return }
        userdefaults.set(self.bookmarkedEvents.sorted(), forKey: "bookmarks_\(year)")
    }
    
    public func save() {
        self.save(to: UserDefaults.standard)
    }
    
    public func load() {
        self.load(from: UserDefaults.standard)
    }
    public func load(from userdefaults: UserDefaults) {
        guard let year = year else { return }
        if let bm = userdefaults.object(forKey: "bookmarks_\(year)") {
            let bookmarks = bm as! [String]
            self.bookmarkedEvents = self.bookmarkedEvents.union(bookmarks)
        }
    }
}
