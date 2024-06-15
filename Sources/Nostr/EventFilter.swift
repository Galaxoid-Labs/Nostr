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
    public let since: Timestamp?
    public let until: Timestamp?
    public let limit: Int?
    
    private let tags: [Tag]
    
    public init(
        ids: [String]? = nil,
        authors: [String]? = nil,
        eventKinds: [EventKind]? = nil,
        since: Timestamp? = nil,
        until: Timestamp? = nil,
        limit: Int? = nil,
        tags: [Tag] = []
    ) {
        self.ids = ids
        self.authors = authors
        self.eventKinds = eventKinds
        self.since = since
        self.until = until
        self.limit = limit
        self.tags = tags
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CustomCodingKeys.self)
        try container.encodeIfPresent(ids, forKey: CustomCodingKeys(stringValue: "ids"))
        try container.encodeIfPresent(authors, forKey: CustomCodingKeys(stringValue: "authors"))
        try container.encodeIfPresent(eventKinds, forKey: CustomCodingKeys(stringValue: "kinds"))
        try container.encodeIfPresent(since, forKey: CustomCodingKeys(stringValue: "since"))
        try container.encodeIfPresent(until, forKey: CustomCodingKeys(stringValue: "until"))
        try container.encodeIfPresent(limit, forKey: CustomCodingKeys(stringValue: "limit"))
        
        for tag in tags {
            let key = tag.id.trimmingPrefix("#") // Since we will add #, we trim # prefix in case user added it themselves
            try container.encode(tag.otherInformation, forKey: CustomCodingKeys(stringValue: "#\(key)"))
        }
    }
    
    private struct CustomCodingKeys: CodingKey {
        var stringValue: String
        var intValue: Int? { return nil }
        
        init(stringValue: String) {
            self.stringValue = stringValue
        }
        
        init?(intValue: Int) {
            return nil
        }
    }
}
