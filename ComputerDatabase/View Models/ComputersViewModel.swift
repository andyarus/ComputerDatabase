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
  
  private var currentPage = 0
  private var totalPages = 0
  private var itemsPerPage = 0
  
  // MARK: - Callbacks
  
  private var onComputersLoadedCallback: (() -> Void)?
  private var onDescriptionLoadedCallback: ((IndexPath) -> Void)?
  private var onErrorCallback: ((Error) -> Void)?
  private var onCurrentPageChangedCallback: ((String) -> Void)?
  private var onPreviousButtonEnabledCallback: ((Bool) -> Void)?
  private var onNextButtonEnabledCallback: ((Bool) -> Void)?
  
  // MARK: - Access Properties
  
  public var numberOfComputers: Int {
    return rowId.count
  }
  
  // MARK: - Access Methods
  
  public func computer(in row: Int) -> Computer? {
    guard let id = rowId[row],
      let computer = computers[id] else { return nil }
    return computer
  }
  
  public func load() {
    loadOperationQueue(for: 0)
  }
  
  public func next() {
    let nextPage = currentPage + 1
    guard nextPage > 0, nextPage < totalPages else { return }
    
    loadOperationQueue(for: nextPage)
    
    if nextPage == 1 {
      onPreviousButtonEnabledCallback?(true)
    }
    if nextPage >= totalPages - 1 {
      onNextButtonEnabledCallback?(false)
    }
  }
  
  public func previous() {
    let previousPage = currentPage - 1
    guard previousPage >= 0, previousPage < totalPages else { return }
    
    loadOperationQueue(for: previousPage)
    
    if previousPage == 0 {
      onPreviousButtonEnabledCallback?(false)
    }
    if previousPage + 1 >= totalPages - 1 {
      onNextButtonEnabledCallback?(true)
    }
  }
  
  // MARK: - Output Methods
  
  @discardableResult
  public func onComputersLoaded(callback: @escaping () -> Void) -> Self {
    onComputersLoadedCallback = callback
    return self
  }
  
  @discardableResult
  public func onDescriptionLoaded(callback: @escaping (IndexPath) -> Void) -> Self {
    onDescriptionLoadedCallback = callback
    return self
  }
  
  @discardableResult
  public func onError(callback: @escaping (Error) -> Void) -> Self {
    onErrorCallback = callback
    return self
  }
  
  @discardableResult
  public func onCurrentPageChanged(callback: @escaping (String) -> Void) -> Self {
    onCurrentPageChangedCallback = callback
    return self
  }
  
  @discardableResult
  public func onPreviousButtonEnabled(callback: @escaping (Bool) -> Void) -> Self {
    onPreviousButtonEnabledCallback = callback
    return self
  }
  
  @discardableResult
  public func onNextButtonEnabled(callback: @escaping (Bool) -> Void) -> Self {
    onNextButtonEnabledCallback = callback
    return self
  }
  
  // MARK: - Load Methods
  
  private func loadOperationQueue(for page: Int) {
    let loadComputersOperation = BlockOperation {
      self.loadComputers(for: page)
    }
    let loadDescriptionOperation = BlockOperation {
      self.loadDescription()
    }
    loadDescriptionOperation.addDependency(loadComputersOperation)

    let operationQueue = OperationQueue()
    operationQueue.addOperation(loadComputersOperation)
    operationQueue.addOperation(loadDescriptionOperation)
  }
  
  private func loadComputers(for page: Int) {
    computers.removeAll()
    rowId.removeAll()
    idRow.removeAll()
    
    let group = DispatchGroup()
    group.enter()
    
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
        self.totalPages = Int(total/self.itemsPerPage) + 1
      }
      self.currentPage = page
      let currentPageDescription = "Page \(self.currentPage+1) of \(self.totalPages)"
      
      DispatchQueue.main.async {
        self.onCurrentPageChangedCallback?(currentPageDescription)
        self.onComputersLoadedCallback?()
      }
      
      group.leave()
    }, onFailure: { [weak self] error in
      print("request error: \(error.localizedDescription)")
      DispatchQueue.main.async {
        let error = NSError(domain: "", code: 0, userInfo: [ NSLocalizedDescriptionKey : "Сould not get the list of computers" ])
        self?.onErrorCallback?(error)
      }
      
      group.leave()
    })
    
    group.wait()
  }
  
  private func loadDescription() {
    for computer in computers.values {
      computerApi.getComputer(for: computer.id, onSuccess: { [weak self] data in
        guard let self = self else { return }
        self.updateComputer(for: computer.id, with: data)
        DispatchQueue.main.async {
          if let row = self.idRow[computer.id] {
            let indexPath = IndexPath(item: row, section: 0)
            self.onDescriptionLoadedCallback?(indexPath)
          }
        }
      }, onFailure: { [weak self] error in
        print("request error: \(error.localizedDescription) for computer:\(computer)")
        DispatchQueue.main.async {
          self?.onErrorCallback?(error)
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

  public func configure(_ cell: ComputerCell, in row: Int) {
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
