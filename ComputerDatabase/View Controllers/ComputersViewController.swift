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
  
  // MARK: - View Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    load()
  }
  
  // MARK: - Load Method
  
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

// MARK: - UITableViewDataSource

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

// MARK: - UITableViewDelegate

extension ComputersViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let sb = UIStoryboard.init(name: "Main", bundle: nil)
    guard let vc = sb.instantiateViewController(withIdentifier: "ComputerViewController") as? ComputerViewController else { return }
    
    let computerItem = computers[indexPath.row]
    
    let computer = Computer(id: computerItem.id, name: computerItem.name, introduced: "introduced", discounted: "discounted", imageUrl: URL(string: "https://www.bhphotovideo.com/images/images1000x1000/lenovo_20ev002fus_15_6_thinkpad_e560_notebook_1219634.jpg")!, company: Company(id: 1, name: "name"), description: "description?")
    
    vc.computer = computer
    navigationController?.pushViewController(vc, animated: true)
  }
  
}
