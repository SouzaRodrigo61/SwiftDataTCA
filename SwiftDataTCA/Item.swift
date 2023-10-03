//
//  Item.swift
//  SwiftDataTCA
//
//  Created by Rodrigo Souza on 03/10/23.
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
