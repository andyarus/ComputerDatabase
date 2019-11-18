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
  
  private let viewModel = ComputerViewModel()
  
  // MARK: - Outlets
  
  @IBOutlet weak var computerTableView: UITableView!
  
  // MARK: - View Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
    setupViewModel()
    
    loadData()
  }
  
  // MARK: - Setup Methods
  
  private func setupViewModel() {
    viewModel
      .onDataLoaded { [weak self] row in
        self?.computerTableView.reloadData()
        //self?.computerTableView.reloadRows(at: [IndexPath(item: row, section: 0)], with: .fade)
      }
      .onError { [weak self] error in
        guard let self = self else { return }
        UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert).show(in: self)
    }
  }
  
  private func setupUI() {
    navigationItem.title = viewModel.computer?.name
  }
  
  public func setupComputer(_ computer: Computer?) {
    viewModel.computer = computer
  }
  
  // MARK: - Load Methods
  
  private func reload() {
    setupUI()
    loadData()
  }
  
  private func loadData() {
    viewModel.load()
  }
  
}

// MARK: - UITableViewDataSource

extension ComputerViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ComputerDescriptionCell", for: indexPath) as! ComputerDescriptionCell
    
    viewModel.configure(cell)
    
    if let _ = viewModel.computer?.description,
      cell.descriptionView.gestureRecognizers == nil {
        cell.descriptionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.descriptionViewClicked(_:))))
    }
    
    if let similarItems = viewModel.computer?.similarItems, similarItems.count > 0 {
      addSubviews(similarItems, to: cell)
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
    viewModel.computer = sender.computer
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
