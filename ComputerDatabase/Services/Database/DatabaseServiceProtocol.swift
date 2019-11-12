//
//  DatabaseServiceProtocol.swift
//  ComputerDatabase
//
//  Created by Andrei Coder on 08/11/2019.
//  Copyright © 2019 yaav. All rights reserved.
//

import Foundation

protocol DatabaseServiceProtocol {
  func createData(for computer: Computer)
  func retrieveData() -> [Computer]
  func retrieveData(by key: String) -> Computer?
  func updateData(for computer: Computer)
  func updateData(for id: Int, with similarItems: [ComputerItemSimilar])
  func updateData(for id: Int, with imageData: Data)
  func deleteData()
}
