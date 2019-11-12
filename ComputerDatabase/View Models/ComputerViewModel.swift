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
  
  // MARK: - Access Properties
  
  public var computer: Computer? {
    get {
      return computerValue
    }
    set {
      computerValue = newValue
    }
  }
  
  // MARK: - Load Methods
  
  public func loadComputer(onSuccess success: @escaping () -> Void,
                           onFailure failure: @escaping (_ error: Error) -> Void) {
    guard let computer = computerValue else { return }
    computerApi.getComputer(for: computer.id, onSuccess: { [weak self] computer in
      guard let self = self else { return }
      self.computerValue = computer
      
      DispatchQueue.main.async {
        success()
      }
    }, onFailure: { error in
      print("request error: \(error.localizedDescription)")
      DispatchQueue.main.async {
        failure(error)
      }
    })
  }
  
  public func loadSimilarItems(onSuccess success: @escaping () -> Void,
                        onFailure failure: @escaping (_ error: Error) -> Void) {
    guard let computer = computerValue else { return }
    computerApi.getComputerSimilar(for: computer, onSuccess: { [weak self] similarItems in
      guard let self = self else { return }
      self.computerValue?.similarItems = similarItems
      DispatchQueue.main.async {
        success()
      }
    }, onFailure: { error in
      print("request error: \(error.localizedDescription)")
      DispatchQueue.main.async {
        failure(error)
      }
    })
  }
  
  public func loadImage(onSuccess success: @escaping () -> Void,
                        onFailure failure: @escaping (_ error: Error) -> Void) {
    // TODO Kingfisher
    guard let computer = computerValue else { return }
    computerApi.getImage(for: computer, onSuccess: { [weak self] imageData in
      guard let self = self,
        let _ = UIImage(data: imageData) else { return }
      self.computerValue?.imageData = imageData
      DispatchQueue.main.async {
        success()
      }
    }, onFailure: { error in
      print("request error: \(error.localizedDescription)")
      DispatchQueue.main.async {
        failure(error)
      }
    })
  }
  
}

// MARK: - Configure

extension ComputerViewModel {
  
  func configure(_ cell: ComputerDescriptionCell) {
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
