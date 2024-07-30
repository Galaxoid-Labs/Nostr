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
    case list
    case groupForumNote
    case groupForumNoteReply
    case groupChatMessage
    case groupChatMessageReply
    case groupJoinRequest
    case groupAddUser
    case groupRemoveUser
    case groupEditMetadata
    case groupAddPermission
    case groupRemovePermission
    case groupDeleteEvent
    case groupEditGroupStatus
    case groupCreate
    case groupMetadata
    case groupAdmins
    case groupMembers
    case custom(UInt16)
    
    public init(id: UInt16) {
        switch id {
            case 0: self = .setMetadata
            case 1: self = .textNote
            case 9: self = .groupChatMessage
            case 10: self = .groupChatMessageReply
            case 11: self = .groupForumNote
            case 12: self = .groupForumNoteReply
            case 9000: self = .groupAddUser
            case 9001: self = .groupRemoveUser
            case 9002: self = .groupEditMetadata
            case 9003: self = .groupAddPermission
            case 9004: self = .groupRemovePermission
            case 9005: self = .groupDeleteEvent
            case 9006: self = .groupEditGroupStatus
            case 9007: self = .groupCreate
            case 9021: self = .groupJoinRequest
            case 39000: self = .groupMetadata
            case 39001: self = .groupAdmins
            case 39002: self = .groupMembers
            case 10009: self = .list
            default: self = .custom(id)
        }
    }
    
    public var id: UInt16 {
        switch self {
            case .setMetadata: return 0
            case .textNote: return 1
            case .custom(let customId): return customId
            case .list: return 10009
            case .groupForumNote: return 11
            case .groupForumNoteReply: return 12
            case .groupChatMessage: return 9
            case .groupChatMessageReply: return 10
            case .groupJoinRequest: return 9021
            case .groupAddUser: return 9000
            case .groupRemoveUser: return 9001
            case .groupEditMetadata: return 9002
            case .groupAddPermission: return 9003
            case .groupRemovePermission: return 9004
            case .groupDeleteEvent: return 9005
            case .groupEditGroupStatus: return 9006
            case .groupCreate: return 9007
            case .groupMetadata: return 39000
            case .groupAdmins: return 39001
            case .groupMembers: return 39002
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
