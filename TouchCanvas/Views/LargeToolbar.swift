//
//  LargeToolbar.swift
//  Doano
//
//  Created by 이삼구 on 25/06/2019.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class LargeToolbar: UIToolbar {

  /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
  override func sizeThatFits(_ size: CGSize) -> CGSize {

    var newSize: CGSize = super.sizeThatFits(size)
    newSize.height = 80  // there to set your toolbar height

    return newSize
  }

  override func draw(_ rect: CGRect) {
    if let context = UIGraphicsGetCurrentContext() {
      context.setLineWidth(1)
      context.move(to: .zero)
      context.addLine(to: CGPoint(x: rect.size.width, y: 0))

      context.setStrokeColor(UIColor.lightGray.cgColor)
      context.strokePath()
    }
  }

}
