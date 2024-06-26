//
//  Subscription.swift
//
//
//  Created by Jacob Davis on 3/25/24.
//  Borrowed alot from https://github.com/cnixbtc/NostrKit
//

import Foundation

public struct Subscription: Codable, Equatable {
    
    public let id: String
    public let filters: [Filter]
    
    public init(filters: [Filter], id: String = UUID().uuidString) {
        self.filters = filters
        self.id = id
    }
}
