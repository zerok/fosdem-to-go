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
        let schedule = try instance.loadFile(url: tinyScheduleFile)
        XCTAssertNotNil(schedule)
        XCTAssertEqual(schedule?.conference.title, "FOSDEM 2020")
        
        // The file contains 2 days
        XCTAssertEqual(schedule?.days.count, 2)
        
        
        XCTAssertEqual(schedule?.days[0].index, 1)
        XCTAssertEqual(schedule?.days[0].date, formatter.date(from: "2020-02-01T00:00:00+01:00"))
        XCTAssertEqual(schedule?.days[1].index, 2)
        XCTAssertEqual(schedule?.days[1].date, formatter.date(from: "2020-02-02T00:00:00+01:00"))
        
        // Day 1 should have at least one room associated with it:
        let rooms = schedule?.days[0].rooms
        XCTAssertGreaterThan(rooms!.count, 0)
        XCTAssertEqual(rooms![0].name, "Janson")
        XCTAssertGreaterThan(rooms![0].events.count, 0)
        XCTAssertEqual(rooms![0].events[0].title, "Welcome to FOSDEM 2020")
        XCTAssertEqual(rooms![0].events[0].id, "9025")
    }

    static var allTests = [
        ("testExample", testLoadFileValid),
    ]
}
