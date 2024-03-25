//
//  ClientMessage.swift
//
//
//  Created by Jacob Davis on 3/25/24.
//  Borrowed alot from https://github.com/cnixbtc/NostrKit
//

import Foundation

public enum ClientMessage: Encodable {
    
    case event(Event)
    case subscribe(Subscription)
    case unsubscribe(String)
    
    static var encoder = JSONEncoder()
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.unkeyedContainer()
        
        switch self {
        case .event(let event):
            try container.encode("EVENT")
            try container.encode(event)
        case .subscribe(let subscription):
            try container.encode("REQ")
            try container.encode(subscription.id)
            try subscription.filters.forEach { try container.encode($0) }
        case .unsubscribe(let subscriptionId):
            try container.encode("CLOSE")
            try container.encode(subscriptionId)
        }
    }
    
    public func string() throws -> String {
        do {
            let data = try ClientMessage.encoder.encode(self)
            guard let result = String(data: data, encoding: .utf8) else { throw ClientMessageError.stringEncodeFailed }
            return result
        } catch {
            throw error
        }
    }
    
    public enum ClientMessageError: Error {
        case stringEncodeFailed
    }
}
