//
//  ComputerCell.swift
//  ComputerDatabase
//
//  Created by Andrei Coder on 05/11/2019.
//  Copyright © 2019 yaav. All rights reserved.
//

import UIKit

class ComputerCell: UITableViewCell {
  static var height: CGFloat = 40.0
  
  @IBOutlet weak var computerNameView: UIView!
  @IBOutlet weak var computerNameLabel: UILabel!
  
  @IBOutlet weak var companyView: UIView!
  @IBOutlet weak var companyLabel: UILabel!
  @IBOutlet weak var companyViewHeightConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var introducedView: UIView!
  @IBOutlet weak var introducedLabel: UILabel!
  @IBOutlet weak var introducedViewHeightConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var discontinuedView: UIView!
  @IBOutlet weak var discontinuedLabel: UILabel!
  @IBOutlet weak var discontinuedViewHeightConstraint: NSLayoutConstraint!
}
