//
//  NetworkServiceProtocol.swift
//  ComputerDatabase
//
//  Created by Andrei Coder on 08/11/2019.
//  Copyright © 2019 yaav. All rights reserved.
//

import Foundation

protocol NetworkServiceProtocol {
  func send(_ request: URLRequest,
    onSuccess success: @escaping (_ data: Data) -> Void,
    onFailure failure: @escaping (_ error: Error) -> Void)
}
