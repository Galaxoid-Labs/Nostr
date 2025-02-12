//
//  Kind.swift
//
//
//  Created by Jacob Davis on 3/25/24.
//  Borrowed alot from https://github.com/cnixbtc/NostrKit
//

import Foundation

public enum Kind: Codable, Equatable, Sendable {
    
    case setMetadata
    case textNote
    case chatMessage
    case threadMessage
    case groupList
    case groupJoinRequest
    case groupPutUser
    case groupRemoveUser
    case groupEditMetadata
    case groupDeleteEvent
    case groupEditGroupStatus
    case groupCreate
    case groupDelete
    case groupCreateInvite
    case groupMetadata
    case groupAdmins
    case groupMembers
    case groupRoles
    case custom(UInt16)
    
    public init(id: UInt16) {
        switch id {
            case 0: self = .setMetadata
            case 1: self = .textNote
            case 9: self = .chatMessage
            case 11: self = .threadMessage
            case 9000: self = .groupPutUser
            case 9001: self = .groupRemoveUser
            case 9002: self = .groupEditMetadata
            case 9005: self = .groupDeleteEvent
            case 9006: self = .groupEditGroupStatus
            case 9007: self = .groupCreate
            case 9008: self = .groupDelete
            case 9009: self = .groupCreateInvite
            case 9021: self = .groupJoinRequest
            case 39000: self = .groupMetadata
            case 39001: self = .groupAdmins
            case 39002: self = .groupMembers
            case 39003: self = .groupRoles
            case 10009: self = .groupList
            default: self = .custom(id)
        }
    }
    
    public var id: UInt16 {
        switch self {
            case .setMetadata: return 0
            case .textNote: return 1
            case .threadMessage: return 11
            case .chatMessage: return 9
            case .groupJoinRequest: return 9021
            case .groupPutUser: return 9000
            case .groupRemoveUser: return 9001
            case .groupEditMetadata: return 9002
            case .groupDeleteEvent: return 9005
            case .groupEditGroupStatus: return 9006
            case .groupCreate: return 9007
            case .groupDelete: return 9008
            case .groupCreateInvite: return 9009
            case .groupMetadata: return 39000
            case .groupAdmins: return 39001
            case .groupMembers: return 39002
            case .groupRoles: return 39003
            case .groupList: return 10009
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
