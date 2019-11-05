//
//  ComputersViewController.swift
//  ComputerDatabase
//
//  Created by Andrei Coder on 05/11/2019.
//  Copyright © 2019 yaav. All rights reserved.
//

import UIKit

class ComputersViewController: UIViewController {
  
  // MARK: - Properties
  var computers: [ComputerItem] = []
  
  // MARK: - Outlets
  
  @IBOutlet weak var computersTableView: UITableView!
  @IBOutlet weak var previousButton: UIButton!
  @IBOutlet weak var nextButton: UIButton!
  @IBOutlet weak var currentPageLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    load()
  }
  
  // MARK: - Load Methods
  
  func load() {
    var item = ComputerItem(id: 1, name: "1", company: Company(id: 1, name: "company1"))
    computers.append(item)
    
    item = ComputerItem(id: 2, name: "2", company: Company(id: 1, name: "company2"))
    computers.append(item)
    
    item = ComputerItem(id: 3, name: "3", company: Company(id: 1, name: ""))
    computers.append(item)
    
    item = ComputerItem(id: 4, name: "4", company: Company(id: 1, name: "company4"))
    computers.append(item)
    
    item = ComputerItem(id: 5, name: "5", company: Company(id: 1, name: "company5"))
    computers.append(item)
  }
  
}

extension ComputersViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return computers.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ComputerCell", for: indexPath) as! ComputerCell
    
    let computer = computers[indexPath.row]
    cell.computerNameLabel.text = computer.name
    
    cell.companyViewHeightConstraint.constant = computer.company != nil ? 40 : 0
    cell.introducedViewHeightConstraint.constant = 0
    cell.discontinuedViewHeightConstraint.constant = 0
    
    return cell
  }
  
}
