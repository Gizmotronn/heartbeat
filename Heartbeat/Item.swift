//
//  Item.swift
//  Heartbeat
//
//  Created by Liam Arbuckle on 8/1/2026.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
