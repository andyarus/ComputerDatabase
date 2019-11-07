//
//  NetworkServiceProtocol.swift
//  ComputerDatabase
//
//  Created by Andrei Coder on 08/11/2019.
//  Copyright © 2019 yaav. All rights reserved.
//

import Foundation

protocol NetworkServiceProtocol {
  func fetchData(with request: URLRequest, _ completion: @escaping (NetworkService.RequestResult) -> Void)
}
