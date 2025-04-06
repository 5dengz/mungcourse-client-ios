//
//  Item.swift
//  mungcourse
//
//  Created by Kyoungho Eom on 4/6/25.
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
