//
//  Filter.swift
//
//
//  Created by Jacob Davis on 3/25/24.
//  Borrowed alot from https://github.com/cnixbtc/NostrKit
//

import Foundation

public struct Filter: Codable, Equatable, Sendable {
    
    public let ids: [String]?
    public let authors: [String]?
    public let kinds: [Kind]?
    public let since: Timestamp?
    public let until: Timestamp?
    public let limit: Int?
    
    private let tags: [Tag]
    
    public init(
        ids: [String]? = nil,
        authors: [String]? = nil,
        kinds: [Kind]? = nil,
        since: Timestamp? = nil,
        until: Timestamp? = nil,
        limit: Int? = nil,
        tags: [Tag] = []
    ) {
        self.ids = ids
        self.authors = authors
        self.kinds = kinds
        self.since = since
        self.until = until
        self.limit = limit
        self.tags = tags
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CustomCodingKeys.self)
        try container.encodeIfPresent(ids, forKey: CustomCodingKeys(stringValue: "ids"))
        try container.encodeIfPresent(authors, forKey: CustomCodingKeys(stringValue: "authors"))
        try container.encodeIfPresent(kinds, forKey: CustomCodingKeys(stringValue: "kinds"))
        try container.encodeIfPresent(since, forKey: CustomCodingKeys(stringValue: "since"))
        try container.encodeIfPresent(until, forKey: CustomCodingKeys(stringValue: "until"))
        try container.encodeIfPresent(limit, forKey: CustomCodingKeys(stringValue: "limit"))
        
        for tag in tags {
            let key = tag.id.trimmingPrefix("#") // Since we will add #, we trim # prefix in case user added it themselves
            try container.encode(tag.otherInformation, forKey: CustomCodingKeys(stringValue: "#\(key)"))
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CustomCodingKeys.self)
        
        ids = try container.decodeIfPresent([String].self, forKey: CustomCodingKeys(stringValue: "ids"))
        authors = try container.decodeIfPresent([String].self, forKey: CustomCodingKeys(stringValue: "authors"))
        kinds = try container.decodeIfPresent([Kind].self, forKey: CustomCodingKeys(stringValue: "kinds"))
        since = try container.decodeIfPresent(Timestamp.self, forKey: CustomCodingKeys(stringValue: "since"))
        until = try container.decodeIfPresent(Timestamp.self, forKey: CustomCodingKeys(stringValue: "until"))
        limit = try container.decodeIfPresent(Int.self, forKey: CustomCodingKeys(stringValue: "limit"))
        
        var decodedTags: [Tag] = []
        for key in container.allKeys {
            if key.stringValue.hasPrefix("#") {
                let tagName = String(key.stringValue.dropFirst())
                let tagValues = try container.decode([String].self, forKey: key)
                decodedTags.append(Tag(id: tagName, otherInformation: tagValues))
            }
        }
        tags = decodedTags
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
