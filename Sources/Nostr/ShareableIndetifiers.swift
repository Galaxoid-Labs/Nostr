//
//  ShareableIdentifiers.swift
//
//  Adapted from https://github.com/nbd-wtf/go-nostr/tree/master/nip19
//
//
//  Created by Jacob Davis on 6/21/24.
//

import Foundation

public struct TLV {
    static let TLVDefault: UInt8 = 0
    static let TLVRelay: UInt8 = 1
    static let TLVAuthor: UInt8 = 2
    static let TLVKind: UInt8 = 3
}

public let nProfilePrefix = "nprofile"
public let nEventPrefix = "nevent"
public let nAddrPrefix = "naddr"
public let notePrefix = "note"

public struct ProfilePointer: Codable {
    public var publicKey: String
    public var relays: [String]
    
    public enum CodingKeys: String, CodingKey {
        case publicKey = "pubkey"
        case relays
    }
}

public struct EventPointer: Codable {
    public var id: String
    public var relays: [String]
    public var author: String?
    public var kind: Int?
    
    public enum CodingKeys: String, CodingKey {
        case id
        case relays
        case author
        case kind
    }
}

public struct EntityPointer: Codable {
    public var publicKey: String
    public var relays: [String]
    public var kind: Int?
    public var identifier: String?
    
    public enum CodingKeys: String, CodingKey {
        case publicKey = "pubkey"
        case relays
        case kind
        case identifier
    }
}

func readTLVEntry(data: [UInt8]) -> (type: UInt8, value: [UInt8]?) {
    guard data.count >= 2 else {
        return (0, nil)
    }

    let type = data[0]
    let length = Int(data[1])
    
    guard data.count >= 2 + length else {
        return (0, nil)
    }
    
    let value = Array(data[2..<2+length])
    return (type, value)
}

func writeTLVEntry(buffer: inout Data, type: UInt8, value: [UInt8]) {
    let length = value.count
    buffer.append(type)
    buffer.append(UInt8(length))
    buffer.append(contentsOf: value)
}

public func encodeNote(withId id: String) throws -> String {
    return try id.bech32FromHex(hrp: notePrefix)
}

public func encodeNEvent(withId id: String, author: String?, relays: [String] = [], kind: Int? = nil) throws -> String {
    guard let id = Data(hexString: id), id.count == 32 else { throw ShareableIndentifierError.invalidEventId }
    var buffer = Data()

    writeTLVEntry(buffer: &buffer, type: TLV.TLVDefault, value: [UInt8](id))
    
    for relay in relays {
        if let relayData = relay.data(using: .utf8) {
            writeTLVEntry(buffer: &buffer, type: TLV.TLVRelay, value: [UInt8](relayData))
        }
    }
   
    if let author {
        guard let pubkey = Data(hexString: author), pubkey.count == 32 else { throw ShareableIndentifierError.publicKeyInvalid }
        writeTLVEntry(buffer: &buffer, type: TLV.TLVAuthor, value: [UInt8](pubkey))
    }
    
    if let kind {
        var kindBytes = [UInt8](repeating: 0, count: 4)
        kindBytes.withUnsafeMutableBytes { (ptr: UnsafeMutableRawBufferPointer) in
            ptr.storeBytes(of: UInt32(kind).bigEndian, as: UInt32.self)
        }
        writeTLVEntry(buffer: &buffer, type: TLV.TLVKind, value: kindBytes)
    }
    
    return bech32Encode(hrp: nEventPrefix, buffer.bytes)
}

public func encodeNProfile(publicKey: String, relays: [String] = []) throws -> String {
    guard let pubkey = Data(hexString: publicKey), pubkey.count == 32 else { throw ShareableIndentifierError.publicKeyInvalid }
    var buffer = Data()
    
    writeTLVEntry(buffer: &buffer, type: TLV.TLVDefault, value: [UInt8](pubkey))
    
    for relay in relays {
        if let relayData = relay.data(using: .utf8) {
            writeTLVEntry(buffer: &buffer, type: TLV.TLVRelay, value: [UInt8](relayData))
        }
    }
    
    return bech32Encode(hrp: nProfilePrefix, buffer.bytes)
}

public func encodeNAddr(publicKey: String, relays: [String] = [], identifier: String, kind: Int) throws -> String {
    guard let pubkey = Data(hexString: publicKey), pubkey.count == 32 else { throw ShareableIndentifierError.publicKeyInvalid }
    var buffer = Data()
    
    if let identifierData = identifier.data(using: .utf8) {
        writeTLVEntry(buffer: &buffer, type: TLV.TLVDefault, value: [UInt8](identifierData))
    }
    
    for relay in relays {
        if let relayData = relay.data(using: .utf8) {
            writeTLVEntry(buffer: &buffer, type: TLV.TLVRelay, value: [UInt8](relayData))
        }
    }
    
    writeTLVEntry(buffer: &buffer, type: TLV.TLVAuthor, value: [UInt8](pubkey))
    
    var kindBytes = [UInt8](repeating: 0, count: 4)
    kindBytes.withUnsafeMutableBytes { (ptr: UnsafeMutableRawBufferPointer) in
        ptr.storeBytes(of: UInt32(kind).bigEndian, as: UInt32.self)
    }
    writeTLVEntry(buffer: &buffer, type: TLV.TLVKind, value: kindBytes)
    
    return bech32Encode(hrp: nAddrPrefix, buffer.bytes)
}

public func decodeNProfile(_ string: String) throws -> ProfilePointer? {
    
    guard string.hasPrefix(nProfilePrefix) else { throw ShareableIndentifierError.wrongPrefix }
    
    var data = Data()
    do {
        if let decoded = try bech32Decode(string, limit: false) {
            data = decoded.data
        }
    } catch {
        throw error
    }
    
    var result = ProfilePointer(publicKey: "", relays: [])
    var curr = 0
    
    while curr < data.count {
        let (t, v) = readTLVEntry(data: Array(data[curr...]))
        guard let v = v else {
            if result.publicKey.isEmpty {
                throw ShareableIndentifierError.publicKeyEmpty
            }
            return result
        }
        
        switch t {
            case TLV.TLVDefault:
                if v.count < 32 {
                    throw ShareableIndentifierError.publicKeyInvalid
                }
                result.publicKey = v.map { String(format: "%02x", $0) }.joined()
            case TLV.TLVRelay:
                result.relays.append(String(decoding: v, as: UTF8.self))
            default:
                break
        }
        
        curr += 2 + v.count
    }
    
    return result
    
}

public func decodeNEvent(_ string: String) throws -> EventPointer? {
    guard string.hasPrefix(nEventPrefix) else { throw ShareableIndentifierError.wrongPrefix }
    
    var data = Data()
    do {
        if let decoded = try bech32Decode(string, limit: false) {
            data = decoded.data
        }
    } catch {
        throw error
    }
    
    var result = EventPointer(id: "", relays: [], author: nil, kind: nil)
    var curr = 0
    
    while curr < data.count {
        let (t, v) = readTLVEntry(data: Array(data[curr...]))
        guard let v = v else {
            if result.id.isEmpty {
                throw ShareableIndentifierError.publicKeyEmpty
            }
            return result
        }
        
        switch t {
            case TLV.TLVDefault:
                if v.count < 32 {
                    throw ShareableIndentifierError.publicKeyInvalid
                }
                result.id = v.map { String(format: "%02x", $0) }.joined()
            case TLV.TLVRelay:
                result.relays.append(String(decoding: v, as: UTF8.self))
            case TLV.TLVAuthor:
                if v.count < 32 {
                    throw ShareableIndentifierError.publicKeyInvalid
                }
                result.author = v.map { String(format: "%02x", $0) }.joined()
            case TLV.TLVKind:
                result.kind = Int(v.withUnsafeBytes { $0.load(as: UInt32.self).bigEndian })
            default:
                break
        }
        
        curr += 2 + v.count
    }
    
    return result
}

public func decodeNAddr(_ string: String) throws -> EntityPointer? {
    guard string.hasPrefix(nAddrPrefix) else { throw ShareableIndentifierError.wrongPrefix }
    
    var data = Data()
    do {
        if let decoded = try bech32Decode(string, limit: false) {
            data = decoded.data
        }
    } catch {
        throw error
    }
    
    var result = EntityPointer(publicKey: "", relays: [], kind: nil, identifier: nil)
    var curr = 0
    
    while curr < data.count {
        let (t, v) = readTLVEntry(data: Array(data[curr...]))
        guard let v = v else {
            if result.kind == 0 || ((result.identifier?.isEmpty) != nil) || result.publicKey.isEmpty {
                throw ShareableIndentifierError.publicKeyEmpty
            }
            return result
        }

        switch t {
        case TLV.TLVDefault:
            result.identifier = String(decoding: v, as: UTF8.self)
        case TLV.TLVRelay:
            result.relays.append(String(decoding: v, as: UTF8.self))
        case TLV.TLVAuthor:
            if v.count < 32 {
                throw ShareableIndentifierError.publicKeyInvalid
            }
            result.publicKey = v.map { String(format: "%02x", $0) }.joined()
        case TLV.TLVKind:
            result.kind = Int(v.withUnsafeBytes { $0.load(as: UInt32.self).bigEndian })
        default:
            break
        }

        curr += 2 + v.count
    }
    
    return result
}

public func decodeNote(_ string: String) throws -> String? {
    return try? string.hexFromBech32(hrp: "note")
}

public enum ShareableIndentifierError: LocalizedError {
    case wrongPrefix
    case dataEncodingFailure
    case publicKeyEmpty
    case publicKeyInvalid
    case invalidEventId

    public var errorDescription: String? {
        switch self {
            case .wrongPrefix:
                return "Prefix's do not match"
            case .dataEncodingFailure:
                return "There was a problem encoding string without prefix"
            case .publicKeyEmpty:
                return "No public key found"
            case .publicKeyInvalid:
                return "No public key is not valid"
            case .invalidEventId:
                return "Event Id is not valid"
        }
    }
}
