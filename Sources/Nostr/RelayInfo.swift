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
    public let contact: String?
    
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
        case contact
    }
    
    public init(description: String? = nil, name: String? = nil, publicKey: String? = nil, 
                software: String? = nil, supportedNips: [Int], version: String? = nil,
                limitation: Limitation? = nil, paymentsUrl: String? = nil,
                fees: Fees? = nil, icon: String? = nil, contact: String? = nil) {
        self.description = description
        self.name = name
        self.publicKey = publicKey
        self.software = software
        self.supportedNips = supportedNips
        self.version = version
        self.limitation = limitation
        self.paymentsUrl = paymentsUrl
        self.fees = fees
        self.icon = icon
        self.contact = contact
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
    
    public init(paymentRequired: Bool? = nil, maxMessageLength: Int? = nil, maxEventTags: Int? = nil,
                maxSubscriptions: Int? = nil, authRequired: Bool? = nil) {
        self.paymentRequired = paymentRequired
        self.maxMessageLength = maxMessageLength
        self.maxEventTags = maxEventTags
        self.maxSubscriptions = maxSubscriptions
        self.authRequired = authRequired
    }
}

public struct Fee: Codable {

    public let amount: Int?
    public let unit: String?
    public let period: Int?
    
    public init(amount: Int? = nil, unit: String? = nil, period: Int? = nil) {
        self.amount = amount
        self.unit = unit
        self.period = period
    }
}

public struct Fees: Codable {

    let subscription: [Fee]
    
    public init(subscription: [Fee]) {
        self.subscription = subscription
    }
}
