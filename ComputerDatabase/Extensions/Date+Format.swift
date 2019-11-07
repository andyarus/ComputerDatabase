//
//  Date+Format.swift
//  ComputerDatabase
//
//  Created by Andrei Coder on 07/11/2019.
//  Copyright © 2019 yaav. All rights reserved.
//

import Foundation

extension Date {
  
  func formatted() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd MMM yyyy"
    
    return dateFormatter.string(from: self)
  }
  
}
