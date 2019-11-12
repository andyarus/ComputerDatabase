//
//  UIScreen+Size.swift
//  ComputerDatabase
//
//  Created by Andrei Coder on 12/11/2019.
//  Copyright © 2019 yaav. All rights reserved.
//

import Foundation
import UIKit

extension UIScreen {
  
  static var isSmall: Bool = {
    return UIScreen.main.bounds.height <= 568
  }()
  
}
