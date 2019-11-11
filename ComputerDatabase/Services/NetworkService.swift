//
//  NetworkService.swift
//  ComputerDatabase
//
//  Created by Andrei Coder on 07/11/2019.
//  Copyright © 2019 yaav. All rights reserved.
//

import Foundation

class NetworkService: NetworkServiceProtocol {
  
  func send(_ request: URLRequest,
            onSuccess success: @escaping (_ data: Data) -> Void,
            onFailure failure: @escaping (_ error: Error) -> Void) {
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
      if let error = error {
        //self.handleClientError(error)
        return failure(error)
      }
      guard let httpResponse = response as? HTTPURLResponse else {
        let error = NSError(domain: "", code: 0, userInfo: [ NSLocalizedDescriptionKey : "Invalid response" ])
        return failure(error)
      }
      guard (200...299).contains(httpResponse.statusCode) else {
        //self.handleServerError(response)
        let error = NSError(domain: "", code: httpResponse.statusCode, userInfo: [ NSLocalizedDescriptionKey : "Invalid status code" ])
        return failure(error)
      }
//      guard let mimeType = httpResponse.mimeType, mimeType == "text/plain" || mimeType == "application/json" else {
//        let error = NSError(domain: "", code: httpResponse.statusCode, userInfo: [ NSLocalizedDescriptionKey : "Invalid MIME type" ])
//        return failure(error)
//      }
      guard let data = data else {
        let error = NSError(domain: "", code: httpResponse.statusCode, userInfo: [ NSLocalizedDescriptionKey : "Data is empty" ])
        return failure(error)
      }
      
      success(data)
    }
    task.resume()
  }
  
}
