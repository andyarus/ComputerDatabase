//
//  ComputerDatabaseApi.swift
//  ComputerDatabase
//
//  Created by Andrei Coder on 12/11/2019.
//  Copyright © 2019 yaav. All rights reserved.
//

import Foundation

final class ComputerDatabaseApi: DatabaseService, ComputerDatabaseApiProtocol {

  func getComputer(for id: Int,
                   onSuccess success: @escaping (_ data: Computer) -> Void,
                   onFailure failure: @escaping (_ error: Error) -> Void) {
    // TODO UIApplication.shared.delegate requires main thread
    DispatchQueue.main.async { [weak self] in
      if let computer = self?.retrieveData(by: String(id)) {
        success(computer)
      } else {
        let error = NSError(domain: "", code: 0, userInfo: [ NSLocalizedDescriptionKey : "Failed retrieve data" ])
        failure(error)
      }
    }
  }
  
  func saveComputer(_ computer: Computer) {
    DispatchQueue.main.async { [weak self] in
      if let _ = self?.retrieveData(by: String(computer.id)) {
        self?.updateData(for: computer)
      } else {
        self?.createData(for: computer)
      }
    }
  }
  
  func saveSimilarItems(_ similarItems: [ComputerItemSimilar], for id: Int) {
    DispatchQueue.main.async { [weak self] in
      self?.updateData(for: id, with: similarItems)
    }
  }
  
  func saveImage(_ imageData: Data, for id: Int) {
    DispatchQueue.main.async { [weak self] in
      self?.updateData(for: id, with: imageData)
    }
  }
  
}
