//
//  ComputerApi.swift
//  ComputerDatabase
//
//  Created by Andrei Coder on 12/11/2019.
//  Copyright © 2019 yaav. All rights reserved.
//

import Foundation

class ComputerApi: ComputerApiProtocol {
  
  private let databaseApi = ComputerDatabaseApi()
  private let networkApi = ComputerNetworkApi()
  
  func getComputers(for page: Int,
                    onSuccess success: @escaping (_ data: [ComputerItem], _ page: Int, _ total: Int) -> Void,
                    onFailure failure: @escaping (_ error: Error) -> Void) {
    networkApi.getComputers(for: page, onSuccess: success, onFailure: failure)
  }
  
  func getComputer(for id: Int,
                   onSuccess success: @escaping (_ data: Computer) -> Void,
                   onFailure failure: @escaping (_ error: Error) -> Void) {
    databaseApi.getComputer(for: id, onSuccess: { [weak self] computer in
      print("databaseApi.getComputer computer:\(computer)")
      //print("computer.updated:\(computer.updated)")
      if let updated = computer.updated,
        let updatedSecond = Calendar.current.dateComponents([.second], from: updated, to: Date()).second,
        updatedSecond < ComputerApiProvider.computer(id: id).updatedLimit {

        print("\nload saved computer")
        
        print("updatedSecond:\(updatedSecond)")
        
        
        success(computer)
      } else {
        print("\nload new computer")
        self?.networkApi.getComputer(for: id, onSuccess: { [weak self] computer in
          success(computer)
          self?.saveComputer(computer)
        }, onFailure: failure)
      }
    }, onFailure: { [weak self] error in
      print("\nload new computer")
      
      self?.networkApi.getComputer(for: id, onSuccess: { [weak self] computer in
        success(computer)
        self?.saveComputer(computer)
      }, onFailure: failure)
    })
  }
  
  func saveComputer(_ computer: Computer) {
    databaseApi.saveComputer(computer)
  }
  
  func getComputerSimilar(for computer: Computer,
                          onSuccess success: @escaping (_ data: [ComputerItemSimilar]) -> Void,
                          onFailure failure: @escaping (_ error: Error) -> Void) {
    
    print()
    print("getComputerSimilar computer.similarItems:\(computer.similarItems)")
    
    if let similarItems = computer.similarItems,
      let updated = computer.updated,
      let updatedSecond = Calendar.current.dateComponents([.second], from: updated, to: Date()).second,
      updatedSecond < ComputerApiProvider.computer(id: computer.id).updatedLimit {
      print("getComputerSimilar same")
      success(similarItems)
    } else {
      print("getComputerSimilar new")
      networkApi.getComputerSimilar(for: computer.id, onSuccess: success, onFailure: failure)
    }
  }
  
  func getImage(for computer: Computer,
                onSuccess success: @escaping (_ data: Data) -> Void,
                onFailure failure: @escaping (_ error: Error) -> Void) {
    if let imageData = computer.imageData,
      let updated = computer.updated,
      let updatedSecond = Calendar.current.dateComponents([.second], from: updated, to: Date()).second,
      updatedSecond < ComputerApiProvider.computer(id: computer.id).updatedLimit {
      print("getImage same")
      success(imageData)
    } else {
      print("getImage new")
      guard let imageUrl = computer.imageUrl else { return }
      networkApi.getImage(for: imageUrl, onSuccess: success, onFailure: failure)
    }
  }
  
}
