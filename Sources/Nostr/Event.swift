//
//  Event.swift
//
//
//  Created by Jacob Davis on 3/24/24.
//

import Foundation
import secp256k1

public struct Event: Codable {
    
    public var id: String? // 32-byte lowercase hex-encoded sha256 of the serialized event data
    public var pubkey: String // 32-byte lowercase hex-encoded public key of the event creator
    public var createdAt: Timestamp // Unix timestamp in seconds
    public var kind: EventKind // Integer between 0 and 65535
    public var tags: [Tag] // Array of arrays of strings for tags
    public var content: String // Arbitrary string content
    public var sig: String? // 64-byte lowercase hex of the signature
    
    enum CodingKeys: String, CodingKey {
        case id, pubkey, createdAt = "created_at", kind, tags, content, sig
    }
    
    public init(id: String? = nil, pubkey: String, createdAt: Timestamp, kind: EventKind, tags: [Tag], content: String, sig: String? = nil) {
        self.id = id
        self.pubkey = pubkey
        self.createdAt = createdAt
        self.kind = kind
        self.tags = tags
        self.content = content
        self.sig = sig
    }
}

struct SerializableEvent: Encodable {
    let id = 0
    let publicKey: String
    let createdAt: Timestamp
    let kind: EventKind
    let tags: [Tag]
    let content: String
    
    static var encoder: JSONEncoder {
        let e = JSONEncoder()
        e.outputFormatting = .withoutEscapingSlashes
        return e
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(id)
        try container.encode(publicKey)
        try container.encode(createdAt)
        try container.encode(kind)
        try container.encode(tags)
        try container.encode(content)
    }
}

extension Event {
    
    public func bech32EncodeEventId() -> String? {
        guard let id else { return nil }
        return try? id.bech32FromHex(hrp: "note")
    }
    
    public static func bech32EncodeEventId(_ id: String) -> String? {
        return try? id.bech32FromHex(hrp: "note")
    }
    
    public static func bech32DecodeEventId(_ id: String) -> String? {
        return try? id.hexFromBech32(hrp: "note")
    }

    func serializableEventData() throws -> Data {
        let serializableEvent = SerializableEvent(
            publicKey: self.pubkey,
            createdAt: self.createdAt,
            kind: self.kind,
            tags: self.tags,
            content: self.content
        )
        return try SerializableEvent.encoder.encode(serializableEvent)
    }
    
    public func hasValidId() -> Bool {
        do {
            let serializableEventData = try serializableEventData()
            return Data(SHA256.hash(data: serializableEventData)).hex() == self.id
        } catch {
            return false
        }
    }
    
    public func isValid() -> Bool {
        guard let id = self.id, id != "" else { return false }
        guard let sig = self.sig, sig != "" else { return false }
        if self.pubkey.isEmpty { return false }
        
        do {
            let serializableEventData = try serializableEventData()
            let idData = Data(SHA256.hash(data: serializableEventData))
            if id != idData.hex() { return false }
            let idBytes = idData.bytes
            guard let sigBytes = Data(hexString: sig)?.bytes else { return false }
            guard let pubkeyBytes = Data(hexString: self.pubkey)?.bytes else { return false }
            
            let ctx = try secp256k1.Context.create()
            var xOnlyPubkey = secp256k1_xonly_pubkey.init()
            let xOnlyPubkeyValid = secp256k1_xonly_pubkey_parse(ctx, &xOnlyPubkey, pubkeyBytes) != 0
            if !xOnlyPubkeyValid { return false }
            return secp256k1_schnorrsig_verify(ctx, sigBytes, idBytes, idBytes.count, &xOnlyPubkey) > 0
        } catch {
            return false
        }
    }

    public mutating func sign(with keyPair: KeyPair) throws {
        do {
            let serializableEventData = try serializableEventData()
            self.id = Data(SHA256.hash(data: serializableEventData)).hex()
            self.sig = try keyPair.sign(data: serializableEventData)
        } catch {
            throw error
        }
    }
}

