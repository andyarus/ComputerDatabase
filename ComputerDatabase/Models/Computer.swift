//
//  Computer.swift
//  ComputerDatabase
//
//  Created by Andrei Coder on 05/11/2019.
//  Copyright © 2019 yaav. All rights reserved.
//

import Foundation

struct Computer: Decodable {
  let id: Int
  let name: String
  let introduced: Date?
  let discounted: Date?
  let imageUrl: URL?
  let company: Company?
  let description: String?
  var similarItems: [ComputerItemSimilar]?
}
