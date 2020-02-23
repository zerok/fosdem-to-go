//
//  TalkDetailsViewController.swift
//  FosdemToGo
//
//  Created by Horst Gutmann on 12.02.20.
//  Copyright © 2020 Horst Gutmann. All rights reserved.
//

import Foundation
import UIKit
import FosdemSchedule
import WebKit
import ReSwift

class TalkDetailsViewController: UIViewController, StoreSubscriber {
    var isBookmarked: Bool {
        get {
            guard let bookmarks = mainStore.state.bookmarkedEvents else { return false }
            return bookmarks.contains(eventID: self.event!.id!)
        }
    }
    func newState(state: AppState) {
        if isBookmarked {
            self.navigationItem.rightBarButtonItem?.image = UIImage(systemName: "bookmark.fill")
        } else {
            self.navigationItem.rightBarButtonItem?.image = UIImage(systemName: "bookmark")
        }
    }
    
    typealias StoreSubscriberStateType = AppState
    
    var event: Event?

    @IBOutlet var titleView: UILabel!
    
    @IBOutlet var abstractView: UITextView!
    
    @IBOutlet var roomNameView: UILabel!
    
    @IBOutlet var timeView: UILabel!
    
    @objc func toggleBookmark(sender: UIBarButtonItem) {
        if isBookmarked {
            mainStore.dispatch(AppStateAction.removeEventFromBookmarks(id: self.event!.id!))
        } else {
            mainStore.dispatch(AppStateAction.addEventToBookmarks(id: self.event!.id!))
        }
    }
    
    @objc func onTitleTap(_ sender: UILabel) {
        guard let u = URL(string: "https://fosdem.org/\(mainStore.state.selectedYear ?? "no-year")/schedule/event/\(self.event?.slug ?? "no-slug")/") else {
            return
        }
        UIApplication.shared.open(u)
    }
    
    @objc func onRoomNameTap(_ sender: UILabel) {
        guard let roomName = self.event?.roomName else { return }
        let normalizedName = roomName.split(separator: " ")[0].filter({
            return $0.isLetter || $0.isNumber
        }).lowercased()
        guard let u = URL(string: "https://nav.fosdem.org/l/\(normalizedName)") else {
            return
        }
        UIApplication.shared.open(u)
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mainStore.subscribe(self)
        let button = UIBarButtonItem(image: UIImage(systemName: "bookmark"), style: .plain, target: self, action: #selector(TalkDetailsViewController.toggleBookmark(sender:)))
        self.navigationItem.rightBarButtonItem = button
        self.navigationItem.largeTitleDisplayMode = .never
        self.newState(state: mainStore.state)
        guard let event = self.event else { return }
        self.titleView.text = event.title
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.onTitleTap(_:)))
        self.titleView.isUserInteractionEnabled = true
        self.titleView.addGestureRecognizer(tap)
        self.abstractView.text = event.abstract?.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        self.roomNameView.text = event.roomName
        self.roomNameView.isUserInteractionEnabled = true
        self.roomNameView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onRoomNameTap(_:))))
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .short
        if let interval = event.interval {
            let start = timeFormatter.string(from: interval.start)
            let end = timeFormatter.string(from: interval.end)
            self.timeView.text = "\(start) - \(end)"
        } else {
            self.timeView.text = "?"
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mainStore.unsubscribe(self)
    }

}
