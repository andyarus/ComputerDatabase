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
  
  private var currentPage = 0
  private var itemsPerPage = 0
  private var totalPages = 0
  
  private var computers: [Int: Computer] = [:] // computer.id: computer
  private var rowId: [Int: Int] = [:]          // tableView row: computer.id
  private var idRow: [Int: Int] = [:]          // computer.id: tableView row
  
  private let computerApi = ComputerApi()
  
  // MARK: - Outlets
  
  @IBOutlet weak var computersTableView: UITableView!
  @IBOutlet weak var previousButton: UIButton!
  @IBOutlet weak var previousButtonWidthConstraint: NSLayoutConstraint!
  @IBOutlet weak var nextButton: UIButton!
  @IBOutlet weak var nextButtonWIdthConstraint: NSLayoutConstraint!
  @IBOutlet weak var currentPageLabel: UILabel!
  
  // MARK: - View Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
    loadComputers(for: currentPage)
  }
  
  // MARK: - Setup Methods
  
  func setup() {
    /// Hide empty cells
    computersTableView.tableFooterView = UIView()
    
    if UIScreen.isSmall {
      previousButtonWidthConstraint.constant = 75
      nextButtonWIdthConstraint.constant = 75
    }
  }
  
  // MARK: - Load Methods
  
  func loadComputers(for page: Int) {
    computers.removeAll()
    rowId.removeAll()
    idRow.removeAll()
    
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
      let currentPageDescription = "Page \(page+1) of \(self.totalPages)"
      
      DispatchQueue.main.async {
        self.computersTableView.reloadData()
        self.currentPageLabel.text = currentPageDescription
      }
      
      self.loadDescription()
    }, onFailure: { [weak self] error in
      guard let self = self else { return }
      UIAlertController(title: "Error", message: "Сould not get the list of computers", preferredStyle: .alert).show(in: self)
      print("request error: \(error.localizedDescription)")
    })
  }
  
  func loadDescription() {
    
    
    
    DispatchQueue.main.async {
      // tmp test
      //DatabaseService().deleteData()
      let computersTmp = DatabaseService().retrieveData()
      print("\ncomputers.count:\(computersTmp.count)")
//      computersTmp.forEach { computer in
//        print("computer:\(computer)")
//      }
    
    }
    
    
    
    for computer in computers.values {
      computerApi.getComputer(for: computer.id, onSuccess: { [weak self] data in
        guard let self = self else { return }
        self.updateComputer(for: computer.id, with: data)
        DispatchQueue.main.async {
          if let row = self.idRow[computer.id] {
            let indexPath = IndexPath(item: row, section: 0)
            self.computersTableView.reloadRows(at: [indexPath], with: .fade)
          }
        }
      }, onFailure: { error in
        print("request error: \(error.localizedDescription) for computer:\(computer)")
      })
    }
  }
  
  func updateComputer(for id: Int, with data: Computer) {
    self.computers[id]?.introduced = data.introduced
    self.computers[id]?.discounted = data.discounted
    self.computers[id]?.imageUrl = data.imageUrl
    self.computers[id]?.company = data.company
    self.computers[id]?.description = data.description    
    self.computers[id]?.updated = data.updated
  }
  
  @IBAction func previousButtonClicked(_ sender: Any) {
    let previousPage = currentPage - 1
    guard previousPage >= 0, previousPage < self.totalPages else { return }
    if previousPage == 0 {
      previousButton.isEnabled = false
      previousButton.alpha = 0.5
    }
    if !nextButton.isEnabled {
      nextButton.isEnabled = true
      nextButton.alpha = 1.0
    }
    loadComputers(for: previousPage)
  }
  
  @IBAction func nextButtonClicked(_ sender: Any) {
    let nextPage = currentPage + 1
    guard nextPage > 0, nextPage < self.totalPages else {
      nextButton.isEnabled = false
      nextButton.alpha = 0.5
      return
    }
    if nextPage == 1 {
      previousButton.isEnabled = true
      previousButton.alpha = 1.0
    }
    loadComputers(for: nextPage)
  }
  
}

// MARK: - UITableViewDataSource

extension ComputersViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return rowId.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ComputerCell", for: indexPath) as! ComputerCell
    
    guard let id = rowId[indexPath.row],
      let computer = computers[id] else { return cell }
    
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
    
    return cell
  }
  
}

// MARK: - UITableViewDelegate

extension ComputersViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let sb = UIStoryboard.init(name: "Main", bundle: nil)
    guard let vc = sb.instantiateViewController(withIdentifier: "ComputerViewController") as? ComputerViewController else { return }
    
    guard let id = rowId[indexPath.row],
      let computer = computers[id] else { return }
    
    vc.computer = computer
    navigationController?.pushViewController(vc, animated: true)
  }
  
}
