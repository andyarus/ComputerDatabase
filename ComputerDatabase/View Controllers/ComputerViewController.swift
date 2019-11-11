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
    
//    // tmp test
//    //databaseService.deleteData()
//    let computers = databaseService.retrieveData()
//    print("computers.count:\(computers.count)")
//    computers.forEach { computer in
//      print("computer:\(computer)")
//    }
    
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
      
//      // tmp
//      guard let computer = self.computer else { return }
//      DispatchQueue.main.async {
//        self.databaseService.createData(for: computer)
//      }
      
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
      //cell.companyViewHeightConstraint.constant = 100
      cell.companyViewHeightConstraint.constant = ComputerDescriptionCell.height
      cell.companyLabel.text = company.name
    } else {
      cell.companyViewHeightConstraint.constant = 0
    }
    if let introduced = computer.introduced {
      cell.introducedViewHeightConstraint.constant = ComputerDescriptionCell.height
      cell.introducedLabel.text = introduced.formatted()
    } else {
      cell.introducedViewHeightConstraint.constant = 0
    }
    if let discounted = computer.discounted {
      cell.discontinuedViewHeightConstraint.constant = ComputerDescriptionCell.height
      cell.discontinuedLabel.text = discounted.formatted()
    } else {
      cell.discontinuedViewHeightConstraint.constant = 0
    }
    
    if let description = computer.description {
      cell.descriptionLabel.text = cell.isExpanded ? description : String(description.prefix(100))
      if cell.descriptionView.gestureRecognizers == nil {
        cell.descriptionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.descriptionViewClicked(_:))))
      }
    } else {
      //cell.descriptionViewHeightConstraint.constant = 0
      // hide description
      cell.addConstraint(cell.descriptionViewHeightConstraint)
    }

    if let imageData = computer.imageData {
      cell.computerImageView.image = UIImage(data: imageData)
    } else {
      // hide imageView
      cell.addConstraint(cell.imageBlockViewHeightConstraint)
    }
    
    if let similarItems = computer.similarItems {
      addSubviews(similarItems, to: cell)
      cell.similarItemsViewHeightConstraint.constant = 180
    } else {
      // hide similarItemsView
      cell.similarItemsView.isHidden = true
      cell.similarItemsViewHeightConstraint.constant = 0
      cell.similarItemsViewTopBorder.isHidden = true
    }
    
    return cell
  }
  
}

// MARK: - Click Processing

extension ComputerViewController {
  
  func addSubviews(_ items: [ComputerItemSimilar], to cell: ComputerDescriptionCell) {
    cell.similarItemsView.subviews.forEach({ if $0 is SimilarItemButton { $0.removeFromSuperview() } })
    
    let buttonHeight: CGFloat = 30.0
    var topOffset: CGFloat = 20.0
    
    for item in items {
      let button = SimilarItemButton(id: item.id)
      button.addTarget(self, action: #selector(similarItemButtonClicked), for: .touchUpInside)
      button.setTitle(item.name, for: .normal)
      
      cell.similarItemsView.addSubview(button)
      button.translatesAutoresizingMaskIntoConstraints = false
      
      NSLayoutConstraint.activate([
        button.heightAnchor.constraint(equalToConstant: buttonHeight),
        button.leadingAnchor.constraint(equalTo: cell.similarItemsView.leadingAnchor, constant: 0.0),
        button.trailingAnchor.constraint(equalTo: cell.similarItemsView.trailingAnchor, constant: 0.0),
        button.topAnchor.constraint(equalTo: cell.similarItemsView.topAnchor, constant: topOffset),
        ])
      
      topOffset += buttonHeight
    }
  }
  
  @objc
  func similarItemButtonClicked(_ sender: SimilarItemButton) {
    print(sender.id)
  }
  
  @objc
  func descriptionViewClicked(_ sender: UITapGestureRecognizer) {
    guard let view = sender.view, let cell = view.superview?.superview as? ComputerDescriptionCell else {
      return
    }
    cell.isExpanded.toggle()
  }
  
}
