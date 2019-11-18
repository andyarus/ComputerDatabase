//
//  ComputerTable.swift
//  ComputerDatabase
//
//  Created by Andrei Coder on 16/11/2019.
//  Copyright © 2019 yaav. All rights reserved.
//

import Foundation

enum ComputerTable: Int {
  case computer     = 0
  case image        = 1
  case similarItems = 2
}

extension ComputerTable {
  
  func row() -> Int {
    return rawValue
  }
  
}
