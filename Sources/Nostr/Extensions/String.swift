//
//  String.swift
//
//
//  Created by Jacob Davis on 3/25/24.
//

import Foundation

public extension String {
    
    func hexFromBech32(hrp: String) throws -> String {
        do {
            if let decoded = try bech32Decode(self) {
                if decoded.hrp == hrp {
                    return decoded.data.hex()
                } else {
                    throw Bech32Error.incorrectHrpSize
                }
            } else {
                throw Bech32Error.decodeFailed
            }
        } catch {
            throw error
        }
    }
    
    func bech32FromHex(hrp: String) throws -> String {
        do {
            return try bech32Encode(hrp: hrp, self.bytes)
        } catch {
            throw error
        }
    }
    
}
