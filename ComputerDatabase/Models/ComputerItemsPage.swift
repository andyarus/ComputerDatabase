//
//  ComputerItemsPage.swift
//  ComputerDatabase
//
//  Created by Andrei Coder on 07/11/2019.
//  Copyright © 2019 yaav. All rights reserved.
//

import Foundation

struct ComputerItemsPage: Decodable {
  let items: [ComputerItem]
  let page: Int
  let offset: Int
  let total: Int
}
