//
//  ClientMessage.swift
//
//
//  Created by Jacob Davis on 3/25/24.
//  Borrowed alot from https://github.com/cnixbtc/NostrKit
//

import Foundation

public enum ClientMessage: Codable {
    
    case event(Event)
    case subscribe(Subscription)
    case unsubscribe(String)
    
    static var encoder = JSONEncoder()
    static var decoder = JSONDecoder()
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let messageType = try container.decode(String.self)
        
        switch messageType {
        case "EVENT":
            let event = try container.decode(Event.self)
            self = .event(event)
        case "REQ":
            let subscriptionId = try container.decode(String.self)
            var filters: [Filter] = []
            while !container.isAtEnd {
                let filter = try container.decode(Filter.self)
                filters.append(filter)
            }
            self = .subscribe(Subscription(filters: filters, id: subscriptionId))
        case "CLOSE":
            let subscriptionId = try container.decode(String.self)
            self = .unsubscribe(subscriptionId)
        default:
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unknown message type: \(messageType)")
        }
    }
    
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
    
    public static func from(string: String) throws -> ClientMessage {
        guard let data = string.data(using: .utf8) else {
            throw ClientMessageError.stringDecodeFailed
        }
        return try decoder.decode(ClientMessage.self, from: data)
    }
    
    public enum ClientMessageError: Error {
        case stringEncodeFailed
        case stringDecodeFailed
    }
}
