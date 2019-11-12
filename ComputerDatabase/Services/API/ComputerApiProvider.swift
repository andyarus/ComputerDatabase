//
//  ComputerApiProvider.swift
//  ComputerDatabase
//
//  Created by Andrei Coder on 12/11/2019.
//  Copyright © 2019 yaav. All rights reserved.
//

import Foundation

enum ComputerApiProvider {
  case computer(id: Int)
}

extension ComputerApiProvider {
  
  var updatedLimit: Int {
    switch self {
    case .computer:
      return 60
    }
  }
  
}
