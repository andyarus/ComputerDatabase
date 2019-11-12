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
      if let updatedDate = computer.updatedDate?.computer,
        let updatedSecond = Calendar.current.dateComponents([.second], from: updatedDate, to: Date()).second,
        updatedSecond < ComputerApiProvider.computer(id: id).updatedLimit {
        success(computer)
      } else {
        self?.networkApi.getComputer(for: id, onSuccess: { [weak self] newComputer in
          let newComputer = newComputer
          newComputer.updatedDate?.similarItems = computer.updatedDate?.similarItems
          newComputer.updatedDate?.image = computer.updatedDate?.image
          success(newComputer)
          self?.databaseApi.saveComputer(newComputer)
        }, onFailure: failure)
      }
    }, onFailure: { [weak self] error in
      self?.networkApi.getComputer(for: id, onSuccess: { [weak self] computer in
        success(computer)
        self?.databaseApi.saveComputer(computer)
      }, onFailure: failure)
    })
  }
  
  func getComputerSimilar(for computer: Computer,
                          onSuccess success: @escaping (_ data: [ComputerItemSimilar]) -> Void,
                          onFailure failure: @escaping (_ error: Error) -> Void) {
    if let similarItems = computer.similarItems,
      let updatedDate = computer.updatedDate?.similarItems,
      let updatedSecond = Calendar.current.dateComponents([.second], from: updatedDate, to: Date()).second,
      updatedSecond < ComputerApiProvider.computer(id: computer.id).updatedLimit {
      success(similarItems)
    } else {
      networkApi.getComputerSimilar(for: computer.id, onSuccess: { [weak self] similarItems in
        success(similarItems)
        self?.databaseApi.saveSimilarItems(similarItems, for: computer.id)
      }, onFailure: failure)
    }
  }
  
  func getImage(for computer: Computer,
                onSuccess success: @escaping (_ data: Data) -> Void,
                onFailure failure: @escaping (_ error: Error) -> Void) {
    if let imageData = computer.imageData,
      let updatedDate = computer.updatedDate?.image,
      let updatedSecond = Calendar.current.dateComponents([.second], from: updatedDate, to: Date()).second,
      updatedSecond < ComputerApiProvider.computer(id: computer.id).updatedLimit {
      success(imageData)
    } else {
      guard let imageUrl = computer.imageUrl else { return }
      networkApi.getImage(for: imageUrl, onSuccess: { [weak self] imageData in
        success(imageData)
        self?.databaseApi.saveImage(imageData, for: computer.id)
      }, onFailure: failure)
    }
  }
  
}
