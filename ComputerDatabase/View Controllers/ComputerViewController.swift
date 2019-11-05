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
  
  // MARK: - View Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  // MARK: - Setup Method
  
  func setup() {
    navigationItem.title = computer?.name
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
    
    cell.companyLabel.text = computer.company?.name
    cell.introducedLabel.text = computer.introduced
    cell.discontinuedLabel.text = computer.discounted
    
    cell.descriptionLabel.text = cell.isExpanded ? computer.description : String(computer.description?.prefix(100) ?? "")
    
    if cell.descriptionView.gestureRecognizers == nil {
      cell.descriptionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.descriptionViewClicked(_:))))
    }
    
    if let imageUrl = computer.imageUrl {
      cell.computerImageView.downloaded(from: imageUrl, contentMode: .scaleToFill)
    } else {
      // hide imageView
      cell.addConstraint(cell.imageBlockViewHeightConstraint)
    }
    
    //cell.companyViewHeightConstraint.constant = computer?.company != nil ? 40 : 0
    //cell.introducedViewHeightConstraint.constant = 0
    //cell.discontinuedViewHeightConstraint.constant = 0
    
    // hide description
    //cell.addConstraint(cell.descriptionViewHeightConstraint)
    
    // hide similarItemsView
    ////cell.addConstraint(cell.similarItemsViewHeightConstraint)
    //cell.similarItemsViewHeightConstraint.constant = 0
    
    addSimilarItems(to: cell)
    
    return cell
  }
  
}

// MARK: - Click Processing

extension ComputerViewController {
  
  func addSimilarItems(to cell: ComputerDescriptionCell) {
    cell.similarItemsView.subviews.forEach({ if $0 is SimilarItemButton { $0.removeFromSuperview() } })
    
    let buttonHeight: CGFloat = 30.0
    var topOffset: CGFloat = 10.0
    
    for i in 0..<5 {
      let button = SimilarItemButton(id: i)
      button.addTarget(self, action: #selector(similarItemButtonClicked), for: .touchUpInside)
      button.setTitle("test", for: .normal)
      
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
