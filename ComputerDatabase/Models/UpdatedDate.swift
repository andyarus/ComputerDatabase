//
//  UpdatedDate.swift
//  ComputerDatabase
//
//  Created by Andrei Coder on 12/11/2019.
//  Copyright © 2019 yaav. All rights reserved.
//

import Foundation

public class UpdatedDate: NSObject, NSCoding {
  var computer: Date?
  var similarItems: Date?
  var image: Date?
  
  init(computer: Date?, similarItems: Date? = nil, image: Date? = nil) {
    self.computer = computer
    self.similarItems = similarItems
    self.image = image
  }
  
  public func encode(with aCoder: NSCoder) {
    aCoder.encode(computer, forKey: "computer")
    aCoder.encode(similarItems, forKey: "similarItems")
    aCoder.encode(image, forKey: "image")
  }
  
  public required init?(coder aDecoder: NSCoder) {
    guard let computer = aDecoder.decodeObject(forKey: "computer") as? Date?,
      let similarItems = aDecoder.decodeObject(forKey: "similarItems") as? Date?,
      let image = aDecoder.decodeObject(forKey: "image") as? Date? else {
        return nil
    }
    self.computer = computer
    self.similarItems = similarItems
    self.image = image
  }
}

