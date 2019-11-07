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
  private let networkService = NetworkService()
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
  
  // MARK: - Load Method
  
  func load() {
    guard let id = computer?.id else { return }
    
    // tmp test
    //databaseService.deleteData()
    let computers = databaseService.retrieveData()
    print("computers.count:\(computers.count)")
    computers.forEach { computer in
      print("computer:\(computer)")
    }
    
    let url = URL(string: "http://testwork.nsd.naumen.ru/rest/computers/\(id)")!
    let request = URLRequest(url: url)
    networkService.fetchData(with: request) { result in
      switch result {
      case .success(let data):
        do {
          let decoder = JSONDecoder()
          decoder.dateDecodingStrategy = .iso8601
          self.computer = try decoder.decode(Computer.self, from: data)
        } catch {
          print("JSON error: \(error.localizedDescription)")
        }
      case .failure(let error):
        // TODO show alert
        print(error)
      }
    }
    
    loadSimilar()
  }
  
  func loadSimilar() {
    guard let id = computer?.id else { return }
    
    let url = URL(string: "http://testwork.nsd.naumen.ru/rest/computers/\(id)/similar")!
    let request = URLRequest(url: url)
    networkService.fetchData(with: request) { result in
      switch result {
      case .success(let data):
        do {
          self.computer?.similarItems = try JSONDecoder().decode([ComputerItemSimilar].self, from: data)
          DispatchQueue.main.async {
            self.computerTableView.reloadData()
          }
        } catch {
          print("JSON error: \(error.localizedDescription)")
        }
      case .failure(let error):
        // TODO show alert
        print(error)
      }
      
      // tmp
      guard let computer = self.computer else { return }
      DispatchQueue.main.async {
        self.databaseService.createData(for: computer)
      }
      
    }
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
    cell.introducedLabel.text = computer.introduced?.formatted()
    cell.discontinuedLabel.text = computer.discounted?.formatted()
    
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
    
    if let similarItems = computer.similarItems {
      addSubviews(similarItems, to: cell)
    }
    
    return cell
  }
  
}

// MARK: - Click Processing

extension ComputerViewController {
  
  func addSubviews(_ items: [ComputerItemSimilar], to cell: ComputerDescriptionCell) {
    cell.similarItemsView.subviews.forEach({ if $0 is SimilarItemButton { $0.removeFromSuperview() } })
    
    let buttonHeight: CGFloat = 30.0
    var topOffset: CGFloat = 10.0
    
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
