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
    static var encoder = JSONEncoder()
    
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
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        
        switch self {
        case .event(let subscriptionId, let event):
            try container.encode("EVENT")
            try container.encode(subscriptionId)
            try container.encode(event)
        case .ok(let subscriptionId, let acceptance, let message):
            try container.encode("OK")
            try container.encode(subscriptionId)
            try container.encode(acceptance)
            try container.encode(message)
        case .eose(let subscriptionId):
            try container.encode("EOSE")
            try container.encode(subscriptionId)
        case .closed(let subscriptionId, let message):
            try container.encode("CLOSED")
            try container.encode(subscriptionId)
            try container.encode(message)
        case .notice(let message):
            try container.encode("NOTICE")
            try container.encode(message)
        case .auth(let challenge):
            try container.encode("AUTH")
            try container.encode(challenge)
        case .other(let items):
            try items.forEach { try container.encode($0) }
        }
    }
    
    public func string() throws -> String {
        do {
            let data = try RelayMessage.encoder.encode(self)
            guard let result = String(data: data, encoding: .utf8) else { throw RelayMessageError.stringEncodeFailed }
            return result
        } catch {
            throw error
        }
    }
    
    public init(text: String) throws {
        guard let data = text.data(using: .utf8) else { throw RelayMessageError.dataEncodeFailed }
        self = try RelayMessage.decoder.decode(RelayMessage.self, from: data)
    }
    
    public enum RelayMessageError: Error {
        case dataEncodeFailed
        case stringEncodeFailed
    }
}
