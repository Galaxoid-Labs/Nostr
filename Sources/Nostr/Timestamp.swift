//
//  Timestamp.swift
//
//
//  Created by Jacob Davis on 3/25/24.
//  Borrowed alot from https://github.com/cnixbtc/NostrKit
//

import Foundation

public struct Timestamp: Codable, Equatable, Sendable {
    
    public let timestamp: UInt64
    
    public init() {
        self = .init(date: Date.now)
    }
    
    public init(date: Date) {
        self = .init(timestamp: UInt64(date.timeIntervalSince1970))
    }
    
    public init(timestamp: UInt64) {
        self.timestamp = timestamp
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        try timestamp = container.decode(UInt64.self)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(timestamp)
    }
}

public extension Timestamp {
    var date: Date {
        return Date(timeIntervalSince1970: TimeInterval(timestamp))
    }
}
