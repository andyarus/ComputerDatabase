//
//  Computer.swift
//  ComputerDatabase
//
//  Created by Andrei Coder on 05/11/2019.
//  Copyright © 2019 yaav. All rights reserved.
//

import Foundation

struct Computer {
  let id: Int
  let name: String
  var introduced: Date?
  var discounted: Date?
  var imageUrl: URL?
  var company: Company?
  var description: String?
  
  var similarItems: [ComputerItemSimilar]?
  var imageData: Data?
  var updatedDate: UpdatedDate?
  
  init(id: Int,
       name: String,
       introduced: Date? = nil,
       discounted: Date? = nil,
       imageUrl: URL? = nil,
       company: Company? = nil,
       description: String? = nil,
       similarItems: [ComputerItemSimilar]? = nil,
       imageData: Data? = nil,
       updatedDate: UpdatedDate? = nil) {
    self.id = id
    self.name = name
    self.introduced = introduced
    self.discounted = discounted
    self.imageUrl = imageUrl
    self.company = company
    self.description = description
    self.similarItems = similarItems
    self.imageData = imageData
    self.updatedDate = updatedDate
  }
}
