//
//  DrawLineAndLabel.swift
//  Doano
//
//  Created by 이삼구 on 31/07/2019.
//  Copyright © 2019 Doai. All rights reserved.
//

import Foundation
import UIKit

public struct DrawLineAndLabel: Codable {
  let drawLines: [DrawLine]
  let labels: [[Int]]

  init(drawLines: [DrawLine], labels: [[Int]]) {
    self.drawLines = drawLines
    self.labels = labels
  }

  func count() -> Int {
    return self.drawLines.count
  }
}
