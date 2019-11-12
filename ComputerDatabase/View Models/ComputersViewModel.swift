//
//  ComputersViewModel.swift
//  ComputerDatabase
//
//  Created by Andrei Coder on 13/11/2019.
//  Copyright © 2019 yaav. All rights reserved.
//

import Foundation

final class ComputersViewModel {
  
  // MARK: - Properties
  
  private let computerApi = ComputerApi()
  
  private var computers: [Int: Computer] = [:] // computer.id: computer
  private var rowId: [Int: Int] = [:]          // tableView row: computer.id
  private var idRow: [Int: Int] = [:]          // computer.id: tableView row
  
  private var currentPageValue = 0
  private var totalPagesValue = 0
  private var itemsPerPage = 0
  
  // MARK: - Access Properties
  
  public var numberOfComputers: Int {
    return rowId.count
  }
  
  public var currentPage: Int {
    return currentPageValue
  }
  
  public var totalPages: Int {
    return totalPagesValue
  }
  
  // MARK: - Access Methods
  
  public func computer(in row: Int) -> Computer? {
    guard let id = rowId[row],
      let computer = computers[id] else { return nil }
    return computer
  }
  
  // MARK: - Load Methods
  
  public func loadComputers(for page: Int,
                     onSuccess success: @escaping (String) -> Void,
                     onFailure failure: @escaping (_ error: Error) -> Void) {
    computers.removeAll()
    rowId.removeAll()
    idRow.removeAll()
    
    computerApi.getComputers(for: page, onSuccess: { [weak self] (computerItems, page, total) in
      guard let self = self else { return }
      for computerItem in computerItems {
        let computer = Computer(id: computerItem.id,
                                name: computerItem.name)
        self.computers[computer.id] = computer
        let row = self.rowId.count
        self.rowId[row] = computer.id
        self.idRow[computer.id] = row
      }
      
      if page == 0, computerItems.count > 0, computerItems.count != self.itemsPerPage {
        self.itemsPerPage = computerItems.count
        self.totalPagesValue = Int(total/self.itemsPerPage) + 1
      }
      self.currentPageValue = page
      let currentPageDescription = "Page \(page+1) of \(self.totalPages)"
      
      DispatchQueue.main.async {
        success(currentPageDescription)
      }
    }, onFailure: { error in
      print("request error: \(error.localizedDescription)")
      DispatchQueue.main.async {
        let error = NSError(domain: "", code: 0, userInfo: [ NSLocalizedDescriptionKey : "Сould not get the list of computers" ])
        failure(error)
      }
    })
  }
  
  public func loadDescription(onSuccess success: @escaping (IndexPath) -> Void,
                     onFailure failure: @escaping (_ error: Error) -> Void) {
    for computer in computers.values {
      computerApi.getComputer(for: computer.id, onSuccess: { [weak self] data in
        guard let self = self else { return }
        self.updateComputer(for: computer.id, with: data)
        DispatchQueue.main.async {
          if let row = self.idRow[computer.id] {
            let indexPath = IndexPath(item: row, section: 0)
            success(indexPath)
          }
        }
      }, onFailure: { error in
        print("request error: \(error.localizedDescription) for computer:\(computer)")
        DispatchQueue.main.async {
          failure(error)
        }
      })
    }
  }
  
  private func updateComputer(for id: Int, with data: Computer) {
    self.computers[id]?.introduced = data.introduced
    self.computers[id]?.discounted = data.discounted
    self.computers[id]?.imageUrl = data.imageUrl
    self.computers[id]?.company = data.company
    self.computers[id]?.description = data.description
    self.computers[id]?.updatedDate = data.updatedDate
  }
  
}

// MARK: - Configure

extension ComputersViewModel {

  func configure(_ cell: ComputerCell, in row: Int) {
    guard let id = rowId[row],
      let computer = computers[id] else { return }
    
    cell.computerNameLabel.text = computer.name
    
    if let company = computer.company {
      cell.companyLabel.text = company.name
      cell.companyView.isHidden = false
    } else {
      cell.companyView.isHidden = true
    }
    if let introduced = computer.introduced {
      cell.introducedLabel.text = introduced.formatted()
      cell.introducedView.isHidden = false
    } else {
      cell.introducedView.isHidden = true
    }
    if let discounted = computer.discounted {
      cell.discontinuedLabel.text = discounted.formatted()
      cell.discontinuedView.isHidden = false
    } else {
      cell.discontinuedView.isHidden = true
    }
  }

}
