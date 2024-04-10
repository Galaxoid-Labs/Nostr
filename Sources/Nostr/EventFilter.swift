//
//  EventFilter.swift
//
//
//  Created by Jacob Davis on 3/25/24.
//  Borrowed alot from https://github.com/cnixbtc/NostrKit
//

import Foundation

public struct EventFilter: Codable {
    public let ids: [String]?
    public let authors: [String]?
    public let eventKinds: [EventKind]?
    public let eTags: [String]?
    public let pTags: [String]?
    public let hTags: [String]?
    public let dTags: [String]?
    public let aTags: [String]?
    public let since: Timestamp?
    public let until: Timestamp?
    public let limit: Int?
    
    private enum CodingKeys: String, CodingKey {
        case ids
        case authors
        case eventKinds = "kinds"
        case eTags = "#e"
        case hTags = "#h"
        case pTags = "#p"
        case dTags = "#d"
        case aTags = "#a"
        case since
        case until
        case limit
    }
    
    public init(
        ids: [String]? = nil,
        authors: [String]? = nil,
        eventKinds: [EventKind]? = nil,
        eTags: [String]? = nil,
        pTags: [String]? = nil,
        hTags: [String]? = nil,
        dTags: [String]? = nil,
        aTags: [String]? = nil,
        since: Timestamp? = nil,
        until: Timestamp? =  nil,
        limit: Int? = nil
    ) {
        self.ids = ids
        self.authors = authors
        self.eventKinds = eventKinds
        self.eTags = eTags
        self.pTags = pTags
        self.hTags = hTags
        self.dTags = pTags
        self.aTags = hTags
        self.since = since
        self.until = until
        self.limit = limit
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(ids, forKey: .ids)
        try container.encodeIfPresent(authors, forKey: .authors)
        try container.encodeIfPresent(eventKinds, forKey: .eventKinds)
        try container.encodeIfPresent(eTags, forKey: .eTags)
        try container.encodeIfPresent(pTags, forKey: .pTags)
        try container.encodeIfPresent(hTags, forKey: .hTags)
        try container.encodeIfPresent(dTags, forKey: .dTags)
        try container.encodeIfPresent(aTags, forKey: .aTags)
        try container.encodeIfPresent(since, forKey: .since)
        try container.encodeIfPresent(until, forKey: .until)
        try container.encodeIfPresent(limit, forKey: .limit)
    }
}
