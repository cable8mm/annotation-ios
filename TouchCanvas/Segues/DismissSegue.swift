//
//  DismissSegue.swift
//  Doano
//
//  Created by 이삼구 on 07/05/2019.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class DismissSegue: UIStoryboardSegue {
  override func perform() {
    source.presentingViewController?.dismiss(animated: true, completion: nil)
  }
}
