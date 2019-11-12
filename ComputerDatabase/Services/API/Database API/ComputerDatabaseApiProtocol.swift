//
//  ComputerDatabaseApiProtocol.swift
//  ComputerDatabase
//
//  Created by Andrei Coder on 12/11/2019.
//  Copyright © 2019 yaav. All rights reserved.
//

import Foundation

protocol ComputerDatabaseApiProtocol {
  func getComputer(for id: Int,
                   onSuccess success: @escaping (_ data: Computer) -> Void,
                   onFailure failure: @escaping (_ error: Error) -> Void)
  func saveComputer(_ computer: Computer)  
  func saveSimilarItems(_ similarItems: [ComputerItemSimilar], for id: Int)
  func saveImage(_ imageData: Data, for id: Int)
}
