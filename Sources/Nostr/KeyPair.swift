//
//  Keypair.swift
//
//
//  Created by Jacob Davis on 3/24/24.
//

import Foundation
import secp256k1

public struct KeyPair {
    
    typealias PrivateKey = secp256k1.Schnorr.PrivateKey
    typealias PublicKey = secp256k1.Schnorr.XonlyKey
    
    private let _privateKey: PrivateKey
    
    public init() throws {
        self._privateKey = try PrivateKey()
    }
    
    public init(data: Data) throws {
        self._privateKey = try PrivateKey(dataRepresentation: data)
    }
    
    public init(hex: String) throws {
        guard let data = Data(hexString: hex) else { throw KeyPairError.hexToDataFailed }
        self = try .init(data: data)
    }
    
    public init(bech32PrivateKey: String) throws {
        guard let decoded = try bech32Decode(bech32PrivateKey) else { throw KeyPairError.bech32DecodeFailed }
        if decoded.hrp == "nsec" {
            self = try .init(data: decoded.data)
        } else {
            throw KeyPairError.bech32DecodeFailed
        }
    }
    
    public func sign(data: Data) throws -> String {
        return try self._privateKey.signature(for: data).dataRepresentation.hex()
    }
    
    public var publicKey: String {
        return Data(self._privateKey.xonly.bytes).hex()
    }
    
    public var privateKey: String {
        return self._privateKey.dataRepresentation.hex()
    }
    
    public var bech32PublicKey: String {
        return bech32Encode(hrp: "npub", self._privateKey.xonly.bytes)
    }
    
    public var bech32PrivateKey: String {
        return bech32Encode(hrp: "nsec", self._privateKey.dataRepresentation.bytes)
    }
    
    public enum KeyPairError: Error {
        case hexToDataFailed
        case bech32DecodeFailed
    }
    
}
