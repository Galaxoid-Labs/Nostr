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
    public let eventTags: [String]?
    public let pubKeyTags: [String]?
    public let hTags: [String]?
    public let since: Timestamp?
    public let until: Timestamp?
    public let limit: Int?
    
    private enum CodingKeys: String, CodingKey {
        case ids
        case authors
        case eventKinds = "kinds"
        case eventTags = "#e"
        case hTags = "#h"
        case pubKeyTags = "#p"
        case since
        case until
        case limit
    }
    
    public init(
        ids: [String]? = nil,
        authors: [String]? = nil,
        eventKinds: [EventKind]? = nil,
        eventTags: [String]? = nil,
        pubKeyTags: [String]? = nil,
        hTags: [String]? = nil,
        since: Timestamp? = nil,
        until: Timestamp? =  nil,
        limit: Int? = nil
    ) {
        self.ids = ids
        self.authors = authors
        self.eventKinds = eventKinds
        self.eventTags = eventTags
        self.pubKeyTags = pubKeyTags
        self.hTags = hTags
        self.since = since
        self.until = until
        self.limit = limit
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(ids, forKey: .ids)
        try container.encodeIfPresent(authors, forKey: .authors)
        try container.encodeIfPresent(eventKinds, forKey: .eventKinds)
        try container.encodeIfPresent(eventTags, forKey: .eventTags)
        try container.encodeIfPresent(pubKeyTags, forKey: .pubKeyTags)
        try container.encodeIfPresent(hTags, forKey: .hTags)
        try container.encodeIfPresent(since, forKey: .since)
        try container.encodeIfPresent(until, forKey: .until)
        try container.encodeIfPresent(limit, forKey: .limit)
    }
}
