//
//  Date.swift
//  
//
//  Created by Jacob Davis on 4/9/24.
//

import Foundation

public extension Date {
    var toTimestamp: Timestamp {
        return Timestamp(date: self)
    }
}
