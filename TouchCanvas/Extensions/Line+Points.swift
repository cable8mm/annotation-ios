//
//  LineToObjects.swift
//  Doano
//
//  Created by 이삼구 on 11/06/2019.
//  Copyright © 2019 Apple. All rights reserved.
//
import UIKit

extension Line {
  func toArray() -> [CGPoint] {
    var points = [CGPoint]()
    points.append(CGPoint(x: 100.0, y: 100.0))
    points.append(CGPoint(x: 200.0, y: 200.0))
    return points
  }
}
