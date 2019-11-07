//
//  NetworkService.swift
//  ComputerDatabase
//
//  Created by Andrei Coder on 07/11/2019.
//  Copyright © 2019 yaav. All rights reserved.
//

import Foundation

class NetworkService {
  
  enum RequestResult {
    case success(Data)
    case failure(Error)
  }
  
  func fetchData(with request: URLRequest, _ completion: @escaping (RequestResult) -> Void) {
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
      if let error = error {
        //self.handleClientError(error)
        return completion(.failure(error))
      }
      guard let httpResponse = response as? HTTPURLResponse else {
        let error = NSError(domain: "", code: 0, userInfo: [ NSLocalizedDescriptionKey : "Invalid response" ])
        return completion(.failure(error))
      }
      guard (200...299).contains(httpResponse.statusCode) else {
        //self.handleServerError(response)
        let error = NSError(domain: "", code: httpResponse.statusCode, userInfo: [ NSLocalizedDescriptionKey : "Invalid status code" ])
        return completion(.failure(error))
      }
      guard let mimeType = httpResponse.mimeType, mimeType == "text/plain" || mimeType == "application/json" else {
        let error = NSError(domain: "", code: httpResponse.statusCode, userInfo: [ NSLocalizedDescriptionKey : "Invalid MIME type" ])
        return completion(.failure(error))
      }
      guard let data = data else {
        let error = NSError(domain: "", code: httpResponse.statusCode, userInfo: [ NSLocalizedDescriptionKey : "Data is empty" ])
        return completion(.failure(error))
      }
      
      return completion(.success(data))
    }
    task.resume()
  }
  
}
