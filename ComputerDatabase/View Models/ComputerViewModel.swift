//
//  ComputerViewModel.swift
//  ComputerDatabase
//
//  Created by Andrei Coder on 13/11/2019.
//  Copyright © 2019 yaav. All rights reserved.
//

import Foundation
import UIKit

final class ComputerViewModel {
  
  // MARK: - Properties
  
  private let computerApi = ComputerApi()
  
  private var computerValue: Computer?
  
  // MARK: - Callbacks
  
  private var onDataLoadedCallback: ((Int) -> Void)?
  private var onErrorCallback: ((Error) -> Void)?
  
  // MARK: - Access Properties
  
  public var computer: Computer? {
    get {
      return computerValue
    }
    set {
      computerValue = newValue
    }
  }
  
  // MARK: - Access Methods
  
  public func load() {
    loadOperationQueue()
  }
  
  // MARK: - Output Methods
  
  @discardableResult
  public func onDataLoaded(callback: @escaping (Int) -> Void) -> Self {
    onDataLoadedCallback = callback
    return self
  }
  
  @discardableResult
  public func onError(callback: @escaping (Error) -> Void) -> Self {
    onErrorCallback = callback
    return self
  }
  
  // MARK: - Load Methods
  
  private func loadOperationQueue() {
    let loadComputerOperation = BlockOperation {
      self.loadComputer()
    }
    let loadImageOperation = BlockOperation {
      self.loadImage()
    }
    let loadSimilarItemsOperation = BlockOperation {
      self.loadSimilarItems()
    }
    loadImageOperation.addDependency(loadComputerOperation)
    loadSimilarItemsOperation.addDependency(loadComputerOperation)
    
    let operationQueue = OperationQueue()
    operationQueue.addOperation(loadComputerOperation)
    operationQueue.addOperation(loadImageOperation)
    operationQueue.addOperation(loadSimilarItemsOperation)
  }
  
  private func loadComputer() {
    let group = DispatchGroup()
    group.enter()
    
    guard let computer = computerValue else { return }
    computerApi.getComputer(for: computer.id, onSuccess: { [weak self] computer in
      guard let self = self else { return }
      self.computerValue = computer
      
      DispatchQueue.main.async {
        self.onDataLoadedCallback?(ComputerTable.computer.row())
      }
      
      group.leave()
    }, onFailure: { [weak self] error in
      print("request error: \(error.localizedDescription)")
      DispatchQueue.main.async { self?.onErrorCallback?(error) }
      
      group.leave()
    })
    
    group.wait()
  }
  
  private func loadImage() {
    // TODO Kingfisher
    guard let computer = computerValue else { return }
    computerApi.getImage(for: computer, onSuccess: { [weak self] imageData in
      guard let self = self,
        let _ = UIImage(data: imageData) else { return }
      self.computerValue?.imageData = imageData
      DispatchQueue.main.async {
        self.onDataLoadedCallback?(ComputerTable.image.row())
      }
    }, onFailure: { error in
      print("request error: \(error.localizedDescription)")
      //DispatchQueue.main.async { self?.onErrorCallback?(error) }
    })
  }
  
  private func loadSimilarItems() {
    guard let computer = computerValue else { return }
    computerApi.getComputerSimilar(for: computer, onSuccess: { [weak self] similarItems in
      guard let self = self else { return }
      self.computerValue?.similarItems = similarItems
      DispatchQueue.main.async {
        self.onDataLoadedCallback?(ComputerTable.similarItems.row())
      }
    }, onFailure: { error in
      print("request error: \(error.localizedDescription)")
      //DispatchQueue.main.async { self?.onErrorCallback?(error) }
    })
  }
  
}

// MARK: - Configure

extension ComputerViewModel {
  
  public func configure(_ cell: ComputerDescriptionCell) {
    guard let computer = computerValue else { return }
    
    cell.selectionStyle = .none
    
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
    if let description = computer.description {
      cell.descriptionLabel.text = cell.isExpanded ? description : "\(String(description.prefix(80)))..."
      cell.descriptionView.isHidden = false
    } else {
      cell.descriptionView.isHidden = true
    }
    if let imageData = computer.imageData {
      cell.computerImageView.image = UIImage(data: imageData)
      cell.computerImageView.isHidden = false
    } else {
      cell.computerImageView.isHidden = true
    }
    if let similarItems = computer.similarItems, similarItems.count > 0 {
      cell.similarItemsView.isHidden = false
    } else {
      cell.similarItemsView.isHidden = true
    }
  }
  
}
