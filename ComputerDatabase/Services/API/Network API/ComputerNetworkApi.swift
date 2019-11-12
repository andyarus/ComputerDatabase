//
//  ComputerNetworkApi.swift
//  ComputerDatabase
//
//  Created by Andrei Coder on 12/11/2019.
//  Copyright © 2019 yaav. All rights reserved.
//

import Foundation

final class ComputerNetworkApi: NetworkService, ComputerNetworkApiProtocol {
  
  func getComputers(for page: Int,
                    onSuccess success: @escaping (_ data: [ComputerItem], _ page: Int, _ total: Int) -> Void,
                    onFailure failure: @escaping (_ error: Error) -> Void) {
    let request = URLRequest(url: ComputerNetworkApiProvider.computers(page: page).url)
    send(request, onSuccess: { data in
      do {
        let computerItemsPage = try JSONDecoder().decode(ComputerItemsPage.self, from: data)
        success(computerItemsPage.items, computerItemsPage.page, computerItemsPage.total)
      } catch {
        failure(error)
      }
    }, onFailure: { (error) in
      failure(error)
    })
  }
  
  func getComputer(for id: Int,
                   onSuccess success: @escaping (_ data: Computer) -> Void,
                   onFailure failure: @escaping (_ error: Error) -> Void) {
    let request = URLRequest(url: ComputerNetworkApiProvider.computer(id: id).url)
    send(request, onSuccess: { data in
      do {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let computerJSON = try decoder.decode(ComputerJSON.self, from: data)
        let computer = Computer(id: computerJSON.id,
                                name: computerJSON.name,
                                introduced: computerJSON.introduced,
                                discounted: computerJSON.discounted,
                                imageUrl: computerJSON.imageUrl,
                                company: computerJSON.company,
                                description: computerJSON.description,
                                similarItems: nil,
                                imageData: nil,
                                updatedDate: UpdatedDate(computer: Date()))
        success(computer)
      } catch {
        failure(error)
      }
    }, onFailure: { (error) in
      failure(error)
    })
  }
  
  func getComputerSimilar(for id: Int,
                          onSuccess success: @escaping (_ data: [ComputerItemSimilar]) -> Void,
                          onFailure failure: @escaping (_ error: Error) -> Void) {
    let request = URLRequest(url: ComputerNetworkApiProvider.computerSimilar(id: id).url)
    send(request, onSuccess: { data in
      do {
        let similarItems = try JSONDecoder().decode([ComputerItemSimilar].self, from: data)
        success(similarItems)
      } catch {
        failure(error)
      }
    }, onFailure: { (error) in
      failure(error)
    })
  }
  
  func getImage(for url: URL,
                onSuccess success: @escaping (_ data: Data) -> Void,
                onFailure failure: @escaping (_ error: Error) -> Void) {
    let request = URLRequest(url: url)
    send(request, onSuccess: { data in
      success(data)
    }, onFailure: { (error) in
      failure(error)
    })
  }
  
}
