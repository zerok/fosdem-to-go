//
//  BookmarksCollectionTests.swift
//  FosdemToGoTests
//
//  Created by Horst Gutmann on 23.02.20.
//  Copyright © 2020 Horst Gutmann. All rights reserved.
//

import XCTest
import Foundation
@testable import FosdemToGo

class BookmarksCollectionTests: XCTestCase {
    func testAddAndRemove() {
        let collection = BookmarksCollection(year: "2020")
        XCTAssertEqual(collection.getEvents().count, 0)
        collection.add(eventID: "123")
        XCTAssertEqual(collection.getEvents().count, 1)
    }
    
    // When loading a BookmarksCollection for the first time, an empty list should be returned.
    func testLoadFirstTime() {
        let ud = UserDefaults(suiteName: #file)
        ud?.removePersistentDomain(forName: #file)
        let collection = BookmarksCollection(year: "2020")
        collection.load(from: ud!)
        XCTAssertEqual(collection.getEvents().count, 0)
    }
    
    func testLoadAndSave() {
        let ud = UserDefaults(suiteName: #file)
        ud?.removePersistentDomain(forName: #file)
        let collection = BookmarksCollection(year: "2020")
        collection.load(from: ud!)
        collection.add(eventID: "123")
        collection.save(to: ud!)
        let reloaded = BookmarksCollection(year: "2020")
        reloaded.load(from: ud!)
        XCTAssertEqual(reloaded.getEvents().count, 1)
    }
}
