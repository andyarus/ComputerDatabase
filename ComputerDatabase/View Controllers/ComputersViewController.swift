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
    let networkService = NetworkService()
    
    let url = URL(string: "http://testwork.nsd.naumen.ru/rest/computers?p=0")!
    let request = URLRequest(url: url)
    networkService.fetchData(with: request) { result in
      switch result {
      case .success(let data):
        do {
          let computerItemsPage = try JSONDecoder().decode(ComputerItemsPage.self, from: data)
          self.computers = computerItemsPage.items
          
          DispatchQueue.main.async {
            self.computersTableView.reloadData()
          }
        } catch {
          print("JSON error: \(error.localizedDescription)")
        }
      case .failure(let error):
        // TODO show alert
        print(error)
      }
    }
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
    
    let computer = Computer(id: computerItem.id, name: computerItem.name, introduced: nil, discounted: nil, imageUrl: nil, company: nil, description: nil, similarItems: nil)
    
    vc.computer = computer
    navigationController?.pushViewController(vc, animated: true)
  }
  
}
