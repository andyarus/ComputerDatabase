//
//  ComputerDescriptionCell.swift
//  ComputerDatabase
//
//  Created by Andrei Coder on 06/11/2019.
//  Copyright © 2019 yaav. All rights reserved.
//

import UIKit

class ComputerDescriptionCell: UITableViewCell {
  static var height: CGFloat = 55.0
  
  var isExpanded: Bool = false
  
  @IBOutlet weak var companyView: UIView!
  @IBOutlet weak var companyLabel: UILabel!
  @IBOutlet weak var companyViewHeightConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var introducedView: UIView!
  @IBOutlet weak var introducedLabel: UILabel!
  @IBOutlet weak var introducedViewHeightConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var discontinuedView: UIView!
  @IBOutlet weak var discontinuedLabel: UILabel!
  @IBOutlet weak var discontinuedViewHeightConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var descriptionView: UIView!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var descriptionViewHeightConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var imageBlockView: UIView!
  @IBOutlet weak var computerImageView: UIImageView!
  @IBOutlet weak var imageBlockViewHeightConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var similarItemsView: UIView!
  @IBOutlet weak var similarItemsViewHeightConstraint: NSLayoutConstraint!  
  @IBOutlet weak var similarItemsViewTopBorder: UIView!
}
