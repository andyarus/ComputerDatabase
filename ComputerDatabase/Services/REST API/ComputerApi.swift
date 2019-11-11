//
//  ComputerApi.swift
//  ComputerDatabase
//
//  Created by Andrei Coder on 11/11/2019.
//  Copyright © 2019 yaav. All rights reserved.
//

import Foundation

final class ComputerApi: NetworkService, ComputerApiProtocol {
  
  func getComputers(for page: Int, onSuccess success: @escaping (_ data: [ComputerItem], _ page: Int, _ total: Int) -> Void, onFailure failure: @escaping (_ error: Error) -> Void) {
    let request = URLRequest(url: ComputerApiProvider.computers(page: page).url)
    send(request, onSuccess: { data in
      do {
        let computerItemsPage = try JSONDecoder().decode(ComputerItemsPage.self, from: data)
        print(computerItemsPage)
        success(computerItemsPage.items, computerItemsPage.page, computerItemsPage.total)
      } catch {
        failure(error)
      }
    }, onFailure: { (error) in
      failure(error)
    })
  }
  
  func getComputer(for id: Int, onSuccess success: @escaping (_ data: Computer) -> Void, onFailure failure: @escaping (_ error: Error) -> Void) {
    let request = URLRequest(url: ComputerApiProvider.computer(id: id).url)
    send(request, onSuccess: { data in
      do {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let computer = try decoder.decode(Computer.self, from: data)
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
    let request = URLRequest(url: ComputerApiProvider.computerSimilar(id: id).url)
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
