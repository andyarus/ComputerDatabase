//
//  ComputerApiProvider.swift
//  ComputerDatabase
//
//  Created by Andrei Coder on 11/11/2019.
//  Copyright © 2019 yaav. All rights reserved.
//

import Foundation

enum ComputerApiProvider {
  case computers(page: Int)
  case computer(id: Int)
  case computerSimilar(id: Int)
}

extension ComputerApiProvider {
  
  var baseURL: URL { return URL(string: "http://testwork.nsd.naumen.ru")! }
  
  var path: String {
    switch self {
    case .computers(let page):
      return "/rest/computers?p=\(page)"
    case .computer(let id):
      return "/rest/computers/\(id)"
    case .computerSimilar(let id):
      return "/rest/computers/\(id)/similar"
    }
  }
  
  var url: URL {
    return URL(string: "\(baseURL.absoluteURL)\(path)")!
  }
  
}
