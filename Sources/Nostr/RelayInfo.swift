//
//  RelayInfo.swift
//
//
//  Created by Jacob Davis on 6/21/24.
//

import Foundation

public struct RelayInfo: Codable {
    
    public let description: String?
    public let name: String?
    public let publicKey: String?
    public let software: String?
    public let supportedNips: [Int]
    public let version: String?
    public let limitation: Limitation?
    public let paymentsUrl: String?
    public let fees: Fees?
    public let icon: String?
    
    public enum CodingKeys: String, CodingKey {
        case description
        case name
        case publicKey = "pubkey"
        case software
        case supportedNips = "supported_nips"
        case version
        case limitation
        case paymentsUrl = "payments_url"
        case fees
        case icon
    }
}

public struct Limitation: Codable {
    public let paymentRequired: Bool?
    public let maxMessageLength: Int?
    public let maxEventTags: Int?
    public let maxSubscriptions: Int?
    public let authRequired: Bool?
    
    public enum CodingKeys: String, CodingKey {
        case paymentRequired = "payment_required"
        case maxMessageLength = "max_message_length"
        case maxEventTags = "max_event_tags"
        case maxSubscriptions = "max_subscriptions"
        case authRequired = "auth_required"
    }
}

public struct Fee: Codable {
    public let amount: Int?
    public let unit: String?
    public let period: Int?
}

public struct Fees: Codable {
    let subscription: [Fee]
}
