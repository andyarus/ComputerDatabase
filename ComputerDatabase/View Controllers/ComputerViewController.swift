//
//  ComputerViewController.swift
//  ComputerDatabase
//
//  Created by Andrei Coder on 05/11/2019.
//  Copyright © 2019 yaav. All rights reserved.
//

import UIKit

class ComputerViewController: UIViewController {
  
  // MARK: - Properties
  
  var computer: Computer?
  
  private let computerApi = ComputerApi()
  
  // MARK: - Outlets
  
  @IBOutlet weak var computerTableView: UITableView!
  
  // MARK: - View Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    reload()
  }
  
  // MARK: - Setup Method
  
  func setup() {
    navigationItem.title = computer?.name
  }
  
  // MARK: - Load Methods
  
  func load() {
    let loadComputerOperation = BlockOperation {
      self.loadComputer()
    }
    let loadSimilarItemsOperation = BlockOperation {
      self.loadSimilarItems()
    }
    let loadImageOperation = BlockOperation {
      self.loadImage()
    }
    loadSimilarItemsOperation.addDependency(loadComputerOperation)
    loadImageOperation.addDependency(loadComputerOperation)
    
    let operationQueue = OperationQueue()
    operationQueue.addOperation(loadComputerOperation)
    operationQueue.addOperation(loadSimilarItemsOperation)
    operationQueue.addOperation(loadImageOperation)
  }
  
  func loadComputer() {
    guard let computer = computer else { return }
    
    let group = DispatchGroup()
    group.enter()
    
    computerApi.getComputer(for: computer.id, onSuccess: { [weak self] computer in
      guard let self = self else { return }
      self.computer = computer
      
      group.leave()
      
      DispatchQueue.main.async {
        self.computerTableView.reloadData()
      }
    }, onFailure: { [weak self] error in
      guard let self = self else { return }
      UIAlertController(title: "Error", message: "Сould not get the computer description", preferredStyle: .alert).show(in: self)
      print("request error: \(error.localizedDescription)")
      
      group.leave()
    })
    
    group.wait()
  }
  
  func loadSimilarItems() {
    guard let computer = computer else { return }
    computerApi.getComputerSimilar(for: computer, onSuccess: { [weak self] similarItems in
      guard let self = self else { return }
      self.computer?.similarItems = similarItems
      DispatchQueue.main.async {
        self.computerTableView.reloadData()
      }      
      /// Update
      if let computer = self.computer {
        self.computerApi.saveComputer(computer)
      }
    }, onFailure: { error in
      print("request error: \(error.localizedDescription)")
    })
  }
  
  func loadImage() {
    // TODO Kingfisher
    guard let computer = computer else { return }
    //guard let imageUrl = computer?.imageUrl else { return }
    computerApi.getImage(for: computer, onSuccess: { [weak self] data in
      guard let self = self,
        let _ = UIImage(data: data) else { return }
      self.computer?.imageData = data
      DispatchQueue.main.async {
        self.computerTableView.reloadData()
      }
    }, onFailure: { error in
      print("request error: \(error.localizedDescription)")
    })
  }
  
  func reload() {
    setup()
    load()
  }
  
}

// MARK: - UITableViewDataSource

extension ComputerViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ComputerDescriptionCell", for: indexPath) as! ComputerDescriptionCell
    
    guard let computer = computer else { return cell }
    
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
      if cell.descriptionView.gestureRecognizers == nil {
        cell.descriptionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.descriptionViewClicked(_:))))
      }
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
      addSubviews(similarItems, to: cell)
      cell.similarItemsView.isHidden = false
    } else {
      cell.similarItemsView.isHidden = true
    }
    
    return cell
  }
  
}

// MARK: - Click Processing

extension ComputerViewController {
  
  func addSubviews(_ items: [ComputerItemSimilar], to cell: ComputerDescriptionCell) {
    cell.similarItemsViewStackView.subviews.forEach({ $0.removeFromSuperview() })
    for item in items {
      let computer = Computer(id: item.id,
                          name: item.name)
      let button = SimilarItemButton(computer: computer)
      button.addTarget(self, action: #selector(similarItemButtonClicked), for: .touchUpInside)
      button.setTitle(item.name, for: .normal)
      
      cell.similarItemsViewStackView.addArrangedSubview(button)
    }
  }
  
  @objc
  func similarItemButtonClicked(_ sender: SimilarItemButton) {
    computer = sender.computer
    reload()
  }
  
  @objc
  func descriptionViewClicked(_ sender: UITapGestureRecognizer) {
    let indexPath = IndexPath(row: 0, section: 0)
    guard let cell = computerTableView.cellForRow(at: indexPath) as? ComputerDescriptionCell else { return }
    cell.isExpanded.toggle()
    // Just fun animation
    UIView.transition(with: computerTableView,
                      duration: 0.75,
                      options: .transitionFlipFromLeft,
                      animations: { [weak self] in
                        self?.computerTableView.reloadData()
    })
  }
  
}
