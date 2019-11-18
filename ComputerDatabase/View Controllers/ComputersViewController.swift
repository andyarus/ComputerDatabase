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
    
    setupUI()
    setupViewModel()
    
    loadData()
  }
  
  // MARK: - Setup Methods
  
  private func setupUI() {
    /// Hide empty cells
    computersTableView.tableFooterView = UIView()
    
    if UIScreen.isSmall {
      previousButtonWidthConstraint.constant = 75
      nextButtonWIdthConstraint.constant = 75
    }
  }
  
  private func setupViewModel() {
    viewModel
      .onComputersLoaded { [weak self] in
        self?.computersTableView.reloadData()
      }
      .onDescriptionLoaded { [weak self] indexPath in
        self?.computersTableView.reloadRows(at: [indexPath], with: .fade)
      }
      .onCurrentPageChanged { [weak self] text in
        self?.currentPageLabel.text = text
      }
      .onError { [weak self] error in
        guard let self = self else { return }
        UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert).show(in: self)
      }
      .onPreviousButtonEnabled { [weak self] enabled in
        self?.previousButton.isEnabled = enabled
        self?.previousButton.alpha = enabled ? 1.0 : 0.5
      }
      .onNextButtonEnabled { [weak self] enabled in
        self?.nextButton.isEnabled = enabled
        self?.nextButton.alpha = enabled ? 1.0 : 0.5
    }
  }
  
  // MARK: - Load Methods
  
  private func loadData() {
    viewModel.load()
  }
  
  @IBAction func previousButtonClicked(_ sender: Any) {
    viewModel.previous()
  }
  
  @IBAction func nextButtonClicked(_ sender: Any) {
    viewModel.next()
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
