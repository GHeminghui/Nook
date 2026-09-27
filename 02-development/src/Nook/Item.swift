//
//  Item.swift
//  Nook
//
//  Created by 何明辉 on 2026/9/27.
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
