//
//  Subscription.swift
//
//
//  Created by Jacob Davis on 3/25/24.
//  Borrowed alot from https://github.com/cnixbtc/NostrKit
//

import Foundation

public struct Subscription: Encodable {
    
    public let id: String
    public let filters: [EventFilter]
    
    public init(filters: [EventFilter], id: String = UUID().uuidString) {
        self.filters = filters
        self.id = id
    }
}
