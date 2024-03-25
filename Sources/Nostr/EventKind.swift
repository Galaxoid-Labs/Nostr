//
//  EventKind.swift
//
//
//  Created by Jacob Davis on 3/25/24.
//  Borrowed alot from https://github.com/cnixbtc/NostrKit
//

import Foundation

public enum EventKind: Codable, Equatable {
    
    case setMetadata
    case textNote
    case custom(UInt16)
    
    public init(id: UInt16) {
        switch id {
        case 0: self = .setMetadata
        case 1: self = .textNote
        default: self = .custom(id)
        }
    }
    
    public var id: UInt16 {
        switch self {
        case .setMetadata: return 0
        case .textNote: return 1
        case .custom(let customId): return customId
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.init(id: try container.decode(UInt16.self))
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.id)
    }
}
