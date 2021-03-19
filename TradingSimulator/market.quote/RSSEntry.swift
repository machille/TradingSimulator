//
//  RSSEntry.swift
//  Trading
//
//  Created by Maroun Achille on 11/10/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Foundation

class RSSEntry  {
    var rssName: String
    var title: String
    var desc: String
    var link: String
    var pubDate: Date

    init(rssName: String, title: String, desc: String, link: String, pubDate: Date) {
        self.rssName = rssName
        self.title = title
        self.desc = desc
        self.link = link
        self.pubDate = pubDate
    }
    
    public var description: String {
        return "rssName \(rssName) title: \(title) \n desc: \(desc) \n link: \(link) - pubDate: \(pubDate)"
    }
}

extension RSSEntry: Equatable {
    static func == (lhs: RSSEntry, rhs: RSSEntry) -> Bool {
        return
            lhs.title == rhs.title &&
            lhs.pubDate == rhs.pubDate
    }
}
