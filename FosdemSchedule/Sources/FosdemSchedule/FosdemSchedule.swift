import Foundation

@available(OSX 10.12, *)
class ScheduleParserDelegate: NSObject, XMLParserDelegate {
    var schedule: Schedule?
    
    private var currentDay: Day = Day()
    private var currentRoom: Room = Room()
    private var currentEvent: Event = Event()
    
    private var inConference: Bool = false
    private var inEvent: Bool = false
    private var string: String = ""
    
    override init() {
        self.schedule = nil
    }
    func parser(_ parser: XMLParser, foundCharacters string: String) {
            self.string += string
    }

    func parser(_ parser: XMLParser, didStartElement: String, namespaceURI: String?, qualifiedName: String?, attributes: [String: String]) {
        self.string = ""
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        switch didStartElement {
        case "schedule":
            self.schedule = Schedule()
        case "event":
            self.inEvent = true
            self.currentEvent.id = attributes["id"]
        case "day":
            self.currentDay = Day()
            self.currentDay.index = Int(attributes["index"] ?? "0")!
            if let rawDate = attributes["date"] {
                self.currentDay.date = df.date(from: rawDate)
            }
        case "conference":
            self.schedule?.conference = Conference()
            self.inConference = true
        case "room":
            if !self.inEvent {
                self.currentRoom.name = attributes["name"]
            }
        default:
            return
        }
    }
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "conference" && self.inConference {
            self.inConference = false
            return
        }
        switch elementName {
        case "title":
            if self.inConference {
                self.schedule?.conference.title = self.string
            } else if self.inEvent {
                self.currentEvent.title = self.string
            }
        case "day":
            self.schedule?.days.append(self.currentDay)
            self.currentDay = Day()
        case "room":
            if !self.inEvent {
                self.currentDay.rooms.append(self.currentRoom)
                self.currentRoom = Room()
            }
        case "event":
            self.currentRoom.events.append(self.currentEvent)
            self.currentEvent = Event()
            self.inEvent = false
        default:
            return
        }
    }
}


@available(OSX 10.12, *)
struct FosdemSchedule {
    func downloadSchedule(year: Int) -> URLSessionDownloadTask {
        var url = "https://fosdem.org/\(year)/schedule/xml"
        let u = URL(string: url)!
        let task = URLSession.shared.downloadTask(with: u)
        task.resume()
        return task
    }
    
    func loadFile(url: URL) throws -> Schedule? {
        let fileStream = InputStream.init(url: url)!
        let parser = XMLParser.init(stream: fileStream)
        let delegate = ScheduleParserDelegate()
        parser.delegate = delegate
        if (!parser.parse()) {
            if let e = parser.parserError {
                throw e
            }
            return nil
        }
        return delegate.schedule
    }
}

class Schedule{
    var conference: Conference = Conference()
    var days: [Day] = []
}

class Room {
    var name: String?
    var events: [Event] = []
}

extension Room: CustomStringConvertible {
    var description: String {
        if let name = self.name {
            return "Room \(name)"
        } else {
            return "Unnamed room"
        }
    }
}

class Conference {
    var title: String
    
    init() {
        self.title = ""
    }
}

class Event {
    var title: String? = nil
    var id: String? = nil
}

class Day {
    var index: Int
    var date: Date?
    var rooms: [Room] = []
    
    init() {
        self.index = 0
        self.date = nil
    }
}
