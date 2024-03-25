//
//  Data.swift
//
//
//  Created by Jacob Davis on 3/24/24.
//

import Foundation

extension Data {
    init?(hexString: String) {
        let len = hexString.count
        guard len % 2 == 0 else { return nil }
        
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{2}", options: .caseInsensitive)
        let range = NSRange(location: 0, length: len)
        guard regex.matches(in: hexString, options: [], range: range).count == len / 2 else { return nil }
        
        var bytes = [UInt8]()
        var index = hexString.startIndex
        while index < hexString.endIndex {
            let nextIndex = hexString.index(index, offsetBy: 2)
            let substr = hexString[index..<nextIndex]
            if let byte = UInt8(substr, radix: 16) {
                bytes.append(byte)
            } else {
                return nil
            }
            index = nextIndex
        }
        
        self.init(bytes)
    }
    
    func hex() -> String {
        return map { String(format: "%02x", $0) }.joined()
    }
}
