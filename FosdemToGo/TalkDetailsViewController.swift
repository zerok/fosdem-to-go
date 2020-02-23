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
    private var bookmarkButton: UIBarButtonItem?
    var isBookmarked: Bool {
        get {
            guard let bookmarks = mainStore.state.bookmarkedEvents else { return false }
            return bookmarks.contains(eventID: self.event!.id!)
        }
    }
    func newState(state: AppState) {
        guard let bookmarkButton = bookmarkButton else { return }
        if isBookmarked {
            bookmarkButton.image = UIImage(systemName: "bookmark.fill")
        } else {
            bookmarkButton.image = UIImage(systemName: "bookmark")
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
    
    @objc func share(sender: UIBarButtonItem) {
        guard let url = self.eventURL else { return }
        guard let event = self.event else { return }
        let str = "\(event.title ?? "")\n\(url)\n\(timeRange)"
        let ctrl = UIActivityViewController(activityItems: [str, url], applicationActivities: nil)
        self.present(ctrl, animated: true, completion: nil)
    }
    
    @objc func onTitleTap(_ sender: UILabel) {
        guard let url = self.eventURL else { return }
        UIApplication.shared.open(url)
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
        self.bookmarkButton = UIBarButtonItem(image: UIImage(systemName: "bookmark"), style: .plain, target: self, action: #selector(TalkDetailsViewController.toggleBookmark(sender:)))
        let shareButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(TalkDetailsViewController.share(sender:)))
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.rightBarButtonItems = [self.bookmarkButton!, shareButton]
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
        self.timeView.text = self.timeRange
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mainStore.unsubscribe(self)
    }
    
    var eventURL: URL? {
        get {
            guard let u = URL(string: "https://fosdem.org/\(mainStore.state.selectedYear ?? "no-year")/schedule/event/\(self.event?.slug ?? "no-slug")/") else {
                return nil
            }
            return u
        }
    }
    
    var timeRange: String {
        guard let event = event else { return "" }
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .short
        if let interval = event.interval {
            let start = timeFormatter.string(from: interval.start)
            let end = timeFormatter.string(from: interval.end)
            return "\(start) - \(end)"
        } else {
            return "?"
        }
    }

}
