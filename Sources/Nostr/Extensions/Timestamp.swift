//
//  Timestamp.swift
//  
//
//  Created by Jacob Davis on 4/9/24.
//

import Foundation

public extension Timestamp {
    var toDate: Date {
        return Date(timeIntervalSince1970: TimeInterval(timestamp))
    }
}
