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
  private let databaseService = DatabaseService()
  
  // MARK: - Outlets
  
  @IBOutlet weak var computerTableView: UITableView!
  
  // MARK: - View Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
    load()
  }
  
  // MARK: - Setup Method
  
  func setup() {
    navigationItem.title = computer?.name
  }
  
  // MARK: - Load Methods
  
  func load() {
    guard let id = computer?.id else { return }
    
    computerApi.getComputer(for: id, onSuccess: { [weak self] computer in
      guard let self = self else { return }
      let similarItems = self.computer?.similarItems // if loaded earlier
      self.computer = computer
      self.computer?.similarItems = similarItems
      self.loadImage()
      DispatchQueue.main.async {
        self.computerTableView.reloadData()
      }
    }, onFailure: { [weak self] error in
      guard let self = self else { return }
      UIAlertController(title: "Error", message: "Сould not get the computer description", preferredStyle: .alert).show(in: self)
      print("request error: \(error.localizedDescription)")
    })
    
    computerApi.getComputerSimilar(for: id, onSuccess: { [weak self] similarItems in
      guard let self = self else { return }
      self.computer?.similarItems = similarItems
      DispatchQueue.main.async {
        self.computerTableView.reloadData()
      }
    }, onFailure: { error in
      print("request error: \(error.localizedDescription)")
    })
    
  }
  
  func loadImage() {
    guard let imageUrl = computer?.imageUrl else { return }
    computerApi.getImage(for: imageUrl, onSuccess: { [weak self] data in
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
    } else {
      cell.companyView.isHidden = true
    }
    if let introduced = computer.introduced {
      cell.introducedLabel.text = introduced.formatted()
    } else {
      cell.introducedView.isHidden = true
    }
    if let discounted = computer.discounted {
      cell.discontinuedLabel.text = discounted.formatted()
    } else {
      cell.discontinuedView.isHidden = true
    }
    if let description = computer.description {
      cell.descriptionLabel.text = cell.isExpanded ? description : "\(String(description.prefix(80)))..."
      if cell.descriptionView.gestureRecognizers == nil {
        cell.descriptionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.descriptionViewClicked(_:))))
      }
    } else {
      cell.descriptionView.isHidden = true
    }
    if let imageData = computer.imageData {
      cell.computerImageView.image = UIImage(data: imageData)
    } else {
      cell.computerImageView.isHidden = true
    }
    if let similarItems = computer.similarItems {
      addSubviews(similarItems, to: cell)
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
      let button = SimilarItemButton(id: item.id)
      button.addTarget(self, action: #selector(similarItemButtonClicked), for: .touchUpInside)
      button.setTitle(item.name, for: .normal)
      
      cell.similarItemsViewStackView.addArrangedSubview(button)
    }
  }
  
  @objc
  func similarItemButtonClicked(_ sender: SimilarItemButton) {
    print(sender.id)
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
