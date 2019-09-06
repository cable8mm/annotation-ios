//
//  Point.swift
//  Doano
//
//  Created by 이삼구 on 30/07/2019.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import UIKit

public struct DrawPoint: Codable {
    let sequenceNumber: Int
    let timestamp: TimeInterval
    let x: CGFloat
    let y: CGFloat
    
    init(sequenceNumber: Int, timestamp: TimeInterval, x: CGFloat, y: CGFloat) {
        self.sequenceNumber = sequenceNumber
        self.timestamp = timestamp
        self.x = x
        self.y = y
    }
}
