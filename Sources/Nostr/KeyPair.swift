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
    
    public var publicKeyBytes: [UInt8] {
        return self._privateKey.xonly.bytes
    }
    
    public var leadingZeroBits: Int {
        var leadingBits = 0
        for x in self.publicKeyBytes {
            leadingBits += x.leadingZeroBitCount
            if x.leadingZeroBitCount != 8 {
                break
            }
        }
        return leadingBits
    }
    
    public enum KeyPairError: Error {
        case hexToDataFailed
        case bech32DecodeFailed
        case vanityHexPrefixInvalid
        case vanityHexSuffixInvalid
        case vanityBech32PrefixInvalid
        case vanityBech32SuffixInvalid
    }
    
    fileprivate static func generateLeadingZeroBitKey(withMinimumLeadingZeroBits lzb: Int = 8) async throws -> KeyPair? {
        while true {
            do {
                try Task.checkCancellation()
                let keyPair = try KeyPair()
                var leadingBits = 0
                for x in keyPair.publicKeyBytes {
                    leadingBits += x.leadingZeroBitCount
                    if leadingBits >= lzb {
                        return keyPair
                    }
                    if x.leadingZeroBitCount != 8 {
                        break
                    }
                }
            } catch {
                throw error
            }
        }
    }
    
    fileprivate static func generateVanityHexKey(leadingHexPrefix: String) async throws -> KeyPair? {
        while true {
            do {
                try Task.checkCancellation()
                let keyPair = try KeyPair()
                if keyPair.publicKey.hasPrefix(leadingHexPrefix) {
                    return keyPair
                }
            } catch {
                throw error
            }
        }
    }
    
    fileprivate static func generateVanityHexKey(trailingHexSuffix: String) async throws -> KeyPair? {
        while true {
            do {
                try Task.checkCancellation()
                let keyPair = try KeyPair()
                if keyPair.publicKey.hasSuffix(trailingHexSuffix) {
                    return keyPair
                }
            } catch {
                throw error
            }
        }
    }
    
    // Should include npub1 with prefix
    fileprivate static func generateVanityBech32Key(leadingBech32Prefix: String) async throws -> KeyPair? {
        while true {
            do {
                try Task.checkCancellation()
                let keyPair = try KeyPair()
                if keyPair.bech32PublicKey.hasPrefix(leadingBech32Prefix) {
                    return keyPair
                }
            } catch {
                throw error
            }
        }
    }
    
    fileprivate static func generateVanityBech32Key(trailingBech32Suffix: String) async throws -> KeyPair? {
        while true {
            do {
                try Task.checkCancellation()
                let keyPair = try KeyPair()
                if keyPair.bech32PublicKey.hasSuffix(trailingBech32Suffix) {
                    return keyPair
                }
            } catch {
                throw error
            }
        }
    }
    
    public static func newLeadingZeroBitKey(withMinimumLeadingZeroBits lzb: Int = 8) async throws -> KeyPair? {
        return try await withThrowingTaskGroup(of: KeyPair?.self, body: { group in
            let cores = getProcessorCount()
            print("Using \(cores) cores")
            for _ in 0..<cores {
                group.addTask {
                    return try await generateLeadingZeroBitKey(withMinimumLeadingZeroBits: lzb)
                }
            }
            
            do {
                for try await result in group {
                    if let keyPair = result {
                        group.cancelAll()
                        return keyPair
                    }
                }
            } catch {
                group.cancelAll()
                throw error
            }
            return nil
        })
    }
    
    public static func newVanityHexKey(leadingHexPrefix: String) async throws -> KeyPair? {
        
        if leadingHexPrefix.isEmpty {
            throw KeyPairError.vanityHexPrefixInvalid
        }
        
        for c in leadingHexPrefix {
            if !c.isHexDigit {
                throw KeyPairError.vanityHexPrefixInvalid
            }
        }
        
        return try await withThrowingTaskGroup(of: KeyPair?.self, body: { group in
            let cores = getProcessorCount()
            print("Using \(cores) cores")
            for _ in 0..<cores {
                group.addTask {
                    return try await generateVanityHexKey(leadingHexPrefix: leadingHexPrefix)
                }
            }
            
            do {
                for try await result in group {
                    if let keyPair = result {
                        group.cancelAll()
                        return keyPair
                    }
                }
            } catch {
                group.cancelAll()
                throw error
            }
            return nil
        })
    }
    
    public static func newVanityHexKey(trailingHexSuffix: String) async throws -> KeyPair? {
        
        if trailingHexSuffix.isEmpty {
            throw KeyPairError.vanityHexSuffixInvalid
        }
        
        for c in trailingHexSuffix {
            if !c.isHexDigit {
                throw KeyPairError.vanityHexSuffixInvalid
            }
        }
        
        return try await withThrowingTaskGroup(of: KeyPair?.self, body: { group in
            let cores = getProcessorCount()
            print("Using \(cores) cores")
            for _ in 0..<cores {
                group.addTask {
                    return try await generateVanityHexKey(trailingHexSuffix: trailingHexSuffix)
                }
            }
            
            do {
                for try await result in group {
                    if let keyPair = result {
                        group.cancelAll()
                        return keyPair
                    }
                }
            } catch {
                group.cancelAll()
                throw error
            }
            return nil
        })
    }
    
    public static func newVanityBech32Key(leadingBech32Prefix: String) async throws -> KeyPair? {
        
        if leadingBech32Prefix.isEmpty {
            throw KeyPairError.vanityBech32PrefixInvalid
        }
        
        if !bech32Set.isSuperset(of: leadingBech32Prefix) {
            throw KeyPairError.vanityBech32PrefixInvalid
        }
        
        let prefixWithNpub = "npub1"+leadingBech32Prefix
        
        return try await withThrowingTaskGroup(of: KeyPair?.self, body: { group in
            let cores = getProcessorCount()
            print("Using \(cores) cores")
            for _ in 0..<cores {
                group.addTask {
                    return try await generateVanityBech32Key(leadingBech32Prefix: prefixWithNpub)
                }
            }
            
            do {
                for try await result in group {
                    if let keyPair = result {
                        group.cancelAll()
                        return keyPair
                    }
                }
            } catch {
                group.cancelAll()
                throw error
            }
            return nil
        })
    }
    
    public static func newVanityBech32Key(trailingBech32Suffix: String) async throws -> KeyPair? {
        
        if trailingBech32Suffix.isEmpty {
            throw KeyPairError.vanityBech32SuffixInvalid
        }
        
        if !bech32Set.isSuperset(of: trailingBech32Suffix) {
            throw KeyPairError.vanityBech32SuffixInvalid
        }
        
        return try await withThrowingTaskGroup(of: KeyPair?.self, body: { group in
            let cores = getProcessorCount()
            print("Using \(cores) cores")
            for _ in 0..<cores {
                group.addTask {
                    return try await generateVanityBech32Key(trailingBech32Suffix: trailingBech32Suffix)
                }
            }
            
            do {
                for try await result in group {
                    if let keyPair = result {
                        group.cancelAll()
                        return keyPair
                    }
                }
            } catch {
                group.cancelAll()
                throw error
            }
            return nil
        })
    }
    
    public static func benchMarkCore() async throws {
        var hashsPerSecond = 0
        print("Benchmarking a single core for 5 seconds...")
        let now = Date.now
        while (now.timeIntervalSinceNow > -5) {
            let key = try? KeyPair()
            let _ = key?.leadingZeroBits
            hashsPerSecond += 1
        }
        print("\(hashsPerSecond) hashes per second, per core")
    }
    
    public static func benchMarkCoreWithBech32() async throws {
        var hashsPerSecond = 0
        print("Benchmarking a single core for 5 seconds...")
        let now = Date.now
        while (now.timeIntervalSinceNow > -5) {
            let key = try? KeyPair()
            let _ = key?.bech32PublicKey
            hashsPerSecond += 1
        }
        print("\(hashsPerSecond) hashes per second, per core")
    }
    
    
}

#if os(Linux)
import Glibc

public func getProcessorCount() -> Int {
    let count = sysconf(_SC_NPROCESSORS_ONLN)
    return count > 0 ? Int(count) : 0
}
#else

public func getProcessorCount() -> Int {
    return ProcessInfo().processorCount
}
#endif
