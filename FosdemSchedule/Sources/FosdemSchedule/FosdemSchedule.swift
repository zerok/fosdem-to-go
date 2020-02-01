import Foundation

@available(macOS 10.12, *)
@available(iOS 10, *)
class ScheduleParserDelegate: NSObject, XMLParserDelegate {
    var schedule: Schedule?
    
    private let timeFormat: DateFormatter = DateFormatter()
    private let dateFormat: DateFormatter = DateFormatter()
    
    private var currentDay: Day = Day()
    private var currentRoom: Room = Room()
    private var currentEvent: Event = Event()
    
    private var inConference: Bool = false
    private var inEvent: Bool = false
    private var string: String = ""
    private var currentStart: Date? = nil
    private var currentDuration: TimeInterval? = nil
    
    override init() {
        self.schedule = nil
        self.dateFormat.dateFormat = "yyyy-MM-dd"
        self.timeFormat.dateFormat = "HH:mm"
    }
    func parser(_ parser: XMLParser, foundCharacters string: String) {
            self.string += string
    }

    func parser(_ parser: XMLParser, didStartElement: String, namespaceURI: String?, qualifiedName: String?, attributes: [String: String]) {
        
        self.string = ""
        switch didStartElement {
        case "schedule":
            self.schedule = Schedule()
        case "event":
            self.inEvent = true
            self.currentEvent.id = attributes["id"]
            self.currentStart = nil
            self.currentDuration = nil
        case "day":
            self.currentDay = Day()
            self.currentDay.index = Int(attributes["index"] ?? "0")!
            if let rawDate = attributes["date"] {
                self.currentDay.date = self.dateFormat.date(from: rawDate)
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
        case "abstract":
            if self.inEvent {
                self.currentEvent.abstract = self.string
            }
        case "description":
            if self.inEvent {
                self.currentEvent.description = self.string
            }
        case "day":
            self.schedule?.days.append(self.currentDay)
            self.currentDay = Day()
        case "start":
            let start = self.timeFormat.date(from: self.string)
            if let st = start {
                let hour = Calendar.current.component(.hour, from: st)
                let minute = Calendar.current.component(.minute, from: st)
                self.currentStart = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: self.currentDay.date!)
            }
        case "duration":
            let dur = self.timeFormat.date(from: self.string)
            if let d = dur {
                let seconds = Int64(Calendar.current.component(.hour, from: d) * 60 * 60 + Calendar.current.component(.minute, from: d) * 60)
                self.currentDuration = TimeInterval(integerLiteral: seconds)
            }
        case "room":
            if !self.inEvent {
                self.currentDay.rooms.append(self.currentRoom)
                self.currentRoom = Room()
            }
        case "event":
            if let start = self.currentStart,
                let dur = self.currentDuration {
                self.currentEvent.interval = DateInterval(start: start, duration: dur)
            }
            self.currentRoom.events.append(self.currentEvent)
            self.currentEvent = Event()
            self.inEvent = false
        default:
            return
        }
    }
}


@available(macOS 10.12, *)
@available(iOS 10, *)
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

@available(macOS 10.12, *)
@available(iOS 10, *)
struct Schedule{
    var conference: Conference = Conference()
    var days: [Day] = []
}

@available(macOS 10.12, *)
@available(iOS 10, *)
struct Room {
    var name: String?
    var events: [Event] = []
}

@available(macOS 10.12, *)
@available(iOS 10, *)
extension Room: CustomStringConvertible {
    var description: String {
        if let name = self.name {
            return "Room \(name)"
        } else {
            return "Unnamed room"
        }
    }
}

@available(macOS 10.12, *)
@available(iOS 10, *)
struct Conference {
    var title: String
    
    init() {
        self.title = ""
    }
}

@available(macOS 10.12, *)
@available(iOS 10, *)
struct Event {
    var title: String? = nil
    var id: String? = nil
    var abstract: String? = nil
    var description: String? = nil
    var interval: DateInterval? = nil
}

@available(macOS 10.12, *)
@available(iOS 10, *)
class Day {
    var index: Int
    var date: Date?
    var rooms: [Room] = []
    
    init() {
        self.index = 0
        self.date = nil
    }
}
