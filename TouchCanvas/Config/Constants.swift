//
//  Constants.swift
//  Doano
//
//  Created by 이삼구 on 07/05/2019.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import UIKit

enum APP_ENV {
    case local
    case development
    case production
}

struct K {
    // MARK: List of Constants
    static let APP_ENV:APP_ENV = .production
    static let API_SERVER_PREFIX = "https://os.doai.ai/"
    static let APP_TITLE = "DoAnno"
    static let LINE_WIDTH:CGFloat = 3.0
    static let LINE_WIDTH_SELECTED:CGFloat = 3.0
    static let LABLE_PLACEHOLDER = "Input Memo"
}
