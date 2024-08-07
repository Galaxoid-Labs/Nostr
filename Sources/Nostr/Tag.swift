//
//  Tag.swift
//
//
//  Created by Jacob Davis on 3/25/24.
//  Borrowed alot from https://github.com/cnixbtc/NostrKit
//

import Foundation

public struct Tag: Codable, Equatable, Sendable {
    private let underlyingData: [String]
    
    public var id: String {
        return underlyingData.first!
    }
    
    public var otherInformation: [String] {
        return Array(underlyingData.suffix(from: 1))
    }
    
    public static func event(otherEventId: String, recommendedRelay: URL? = nil) -> Tag {
        return Tag(id: "e", otherInformation: otherEventId, recommendedRelay?.absoluteString)
    }
    
    public static func pubKey(publicKey: String, recommendedRelay: URL? = nil) -> Tag {
        return Tag(id: "p", otherInformation: publicKey, recommendedRelay?.absoluteString)
    }
    
    public init(underlyingData: [String]) {
        self.underlyingData = underlyingData
    }
    
    public init(id: String, otherInformation: String?...) {
        underlyingData = [id] + otherInformation.compactMap { $0 }
    }
    
    public init(id: String, otherInformation: [String]?) {
        if let otherInformation {
            underlyingData = [id] + otherInformation.compactMap { $0 }
        } else {
            underlyingData = [id]
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        underlyingData = try container.decode([String].self)
        
        guard underlyingData.count > 0 else {
            throw DecodingError.dataCorrupted(.init(codingPath: .init(), debugDescription: "missing required tag id"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(contentsOf: underlyingData)
    }
}
