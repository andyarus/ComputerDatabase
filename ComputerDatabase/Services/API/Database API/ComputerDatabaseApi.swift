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
    // TODO UIApplication.shared.delegate requires main thread
    DispatchQueue.main.async { [weak self] in
      print("saveComputer:\(computer)")
      if let _ = self?.retrieveData(by: String(computer.id)) {
        print("update")
        self?.updateData(for: computer)
      } else {
        print("createData")
        self?.createData(for: computer)
      }
    }
  }
  
}
