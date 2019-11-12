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
  
  private let viewModel = ComputersViewModel()
  
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
    
    load(for: viewModel.currentPage)
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
  
  func load(for page: Int) {
    let loadComputersOperation = BlockOperation {
      self.loadComputers(for: page)
    }
    let loadDescriptionOperation = BlockOperation {
      self.loadDescription()
    }
    loadDescriptionOperation.addDependency(loadComputersOperation)

    let operationQueue = OperationQueue()
    operationQueue.addOperation(loadComputersOperation)
    operationQueue.addOperation(loadDescriptionOperation)
  }
  
  func loadComputers(for page: Int) {
    let group = DispatchGroup()
    group.enter()
    
    viewModel.loadComputers(for: page, onSuccess: { [weak self] text in
      self?.computersTableView.reloadData()
      self?.currentPageLabel.text = text
      
      group.leave()
    }, onFailure: { [weak self] error in
      guard let self = self else { return }
      UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert).show(in: self)
      
      group.leave()
    })
    
    group.wait()
  }
  
  func loadDescription() {
    guard viewModel.numberOfComputers > 0 else { return }    
    viewModel.loadDescription(onSuccess: { [weak self] indexPath in
      self?.computersTableView.reloadRows(at: [indexPath], with: .fade)
    }, onFailure: { [weak self] error in
      guard let self = self else { return }
      UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert).show(in: self)
    })
  }
  
  @IBAction func previousButtonClicked(_ sender: Any) {
    let previousPage = viewModel.currentPage - 1
    guard previousPage >= 0, previousPage < viewModel.totalPages else { return }
    if previousPage == 0 {
      previousButton.isEnabled = false
      previousButton.alpha = 0.5
    }
    if !nextButton.isEnabled {
      nextButton.isEnabled = true
      nextButton.alpha = 1.0
    }
    
    load(for: previousPage)
  }
  
  @IBAction func nextButtonClicked(_ sender: Any) {
    let nextPage = viewModel.currentPage + 1
    guard nextPage > 0, nextPage < viewModel.totalPages else {
      nextButton.isEnabled = false
      nextButton.alpha = 0.5
      return
    }
    if nextPage == 1 {
      previousButton.isEnabled = true
      previousButton.alpha = 1.0
    }
    
    load(for: nextPage)
  }
  
}

// MARK: - UITableViewDataSource

extension ComputersViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.numberOfComputers
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ComputerCell", for: indexPath) as! ComputerCell
    
    viewModel.configure(cell, in: indexPath.row)
    
    return cell
  }
  
}

// MARK: - UITableViewDelegate

extension ComputersViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let sb = UIStoryboard.init(name: "Main", bundle: nil)
    guard let vc = sb.instantiateViewController(withIdentifier: "ComputerViewController") as? ComputerViewController else { return }
    
    guard let computer = viewModel.computer(in: indexPath.row) else { return }    
    vc.setupComputer(computer)
    
    navigationController?.pushViewController(vc, animated: true)
  }
  
}
