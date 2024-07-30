//
//  RelayMessage.swift
//
//
//  Created by Jacob Davis on 3/25/24.
//  Borrowed alot from https://github.com/cnixbtc/NostrKit
//

import Foundation

public enum RelayMessage: Codable {
    
    case event(String, Event)
    case ok(String, Bool, String)
    case eose(String)
    case closed(String, String)
    case notice(String)
    case auth(String)
    case other([String])
    
    static var decoder = JSONDecoder()
    
    public init(from decoder: Decoder) throws {
        
        var container = try decoder.unkeyedContainer()
        let messageType = try container.decode(String.self)
        
        switch messageType {
            case "EVENT":
                let subscriptionId = try container.decode(String.self)
                let event = try container.decode(Event.self)
                self = .event(subscriptionId, event)
            case "OK":
                let subscriptionId = try container.decode(String.self)
                let acceptance = try container.decode(Bool.self)
                let message = try container.decode(String.self)
                self = .ok(subscriptionId, acceptance, message)
            case "EOSE":
                self = .eose(try container.decode(String.self))
            case "CLOSED":
                let subscriptionId = try container.decode(String.self)
                let message = try container.decode(String.self)
                self = .closed(subscriptionId, message)
            case "NOTICE":
                self = .notice(try container.decode(String.self))
            case "AUTH":
                self = .auth(try container.decode(String.self))
            default:
                let remainingItemsCount = (container.count ?? 1) - 1
                let remainingItems = try (0..<remainingItemsCount).map { _ in try container.decode(String.self) }
                self = .other([messageType] + remainingItems)
        }
    }
    
    public init(text: String) throws {
        guard let data = text.data(using: .utf8) else { throw RelayMessageError.dataEncodeFailed }
        self = try RelayMessage.decoder.decode(RelayMessage.self, from: data)
    }
    
    public enum RelayMessageError: Error {
        case dataEncodeFailed
    }
}
