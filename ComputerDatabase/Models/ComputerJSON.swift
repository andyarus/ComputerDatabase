//
//  ComputerJSON.swift
//  ComputerDatabase
//
//  Created by Andrei Coder on 12/11/2019.
//  Copyright © 2019 yaav. All rights reserved.
//

import Foundation

struct ComputerJSON: Decodable {
  let id: Int
  let name: String
  var introduced: Date?
  var discounted: Date?
  var imageUrl: URL?
  var company: Company?
  var description: String?
}
