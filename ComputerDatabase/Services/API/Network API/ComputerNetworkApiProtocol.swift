//
//  ComputerNetworkApiProtocol.swift
//  ComputerDatabase
//
//  Created by Andrei Coder on 12/11/2019.
//  Copyright © 2019 yaav. All rights reserved.
//

import Foundation

protocol ComputerNetworkApiProtocol {
  func getComputers(for page: Int,
                    onSuccess success: @escaping (_ data: [ComputerItem], _ page: Int, _ total: Int) -> Void,
                    onFailure failure: @escaping (_ error: Error) -> Void)
  func getComputer(for id: Int,
                   onSuccess success: @escaping (_ data: Computer) -> Void,
                   onFailure failure: @escaping (_ error: Error) -> Void)
  func getComputerSimilar(for id: Int,
                          onSuccess success: @escaping (_ data: [ComputerItemSimilar]) -> Void,
                          onFailure failure: @escaping (_ error: Error) -> Void)
  func getImage(for url: URL,
                onSuccess success: @escaping (_ data: Data) -> Void,
                onFailure failure: @escaping (_ error: Error) -> Void)
}
