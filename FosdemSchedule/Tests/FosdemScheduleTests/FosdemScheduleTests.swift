import XCTest
@testable import FosdemSchedule

@available(iOS 10.0, *)
@available(OSX 10.12, *)
final class FosdemScheduleTests: XCTestCase {
    override func setUp() {
        super.setUp()
        self.continueAfterFailure = false
    }
    func getDataURL(file: String) -> URL {
        let u = URL.init(fileURLWithPath: #file)
        return u.deletingLastPathComponent().appendingPathComponent("data").appendingPathComponent(file)
    }
    func testLoadFileValid() throws {
        let tinyScheduleFile = self.getDataURL(file: "tiny-schedule.xml")
        let formatter = ISO8601DateFormatter()
        let instance = FosdemSchedule()
        guard let schedule = try instance.loadFile(url: tinyScheduleFile) else {
            XCTFail()
            return
        }
        XCTAssertEqual(schedule.conference.title, "FOSDEM 2020")
        
        // The file contains 2 days
        XCTAssertEqual(schedule.days.count, 2)
        
        XCTAssertEqual(schedule.days[0].index, 1)
        XCTAssertEqual(schedule.days[0].date, formatter.date(from: "2020-02-01T00:00:00+01:00"))
        XCTAssertEqual(schedule.days[1].index, 2)
        XCTAssertEqual(schedule.days[1].date, formatter.date(from: "2020-02-02T00:00:00+01:00"))
        
        // Day 1 should have only 1 track: Track A
        XCTAssertEqual(schedule.days[0].tracks, ["Track A"])
        
        // Day 1 should have at least one room associated with it:
        let rooms = schedule.days[0].rooms
        XCTAssertGreaterThan(rooms.count, 0)
        if !rooms.isEmpty {
            let firstRoom = rooms[0]
            XCTAssertEqual(firstRoom.name, "Janson")
            XCTAssertGreaterThan(firstRoom.events.count, 0)
            
            if !firstRoom.events.isEmpty {
                let firstEvent = firstRoom.events[0]
                XCTAssertEqual(firstEvent.title, "Welcome to FOSDEM 2020")
                XCTAssertEqual(firstEvent.id, "9025")
                XCTAssertNotNil(firstEvent.abstract)
                XCTAssertNotNil(firstEvent.description)
                XCTAssertEqual(firstEvent.track, "Track A")
                
                let start = "2020-02-01T09:30:00+01:00"
                let end = "2020-02-01T09:55:00+01:00"
                let startDate = formatter.date(from: start)!
                let endDate = formatter.date(from: end)!
                XCTAssertEqual(firstEvent.interval?.start, startDate)
                XCTAssertEqual(firstEvent.interval?.end, endDate)
            }
        }
        
        XCTAssertEqual(schedule.tracks, ["Track A", "Track B"])
    }

    static var allTests = [
        ("testExample", testLoadFileValid),
    ]
}
