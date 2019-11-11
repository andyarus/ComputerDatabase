//
//  SimilarItemButton.swift
//  ComputerDatabase
//
//  Created by Andrei Coder on 06/11/2019.
//  Copyright © 2019 yaav. All rights reserved.
//

import UIKit

class SimilarItemButton: UIButton {
  
  let computer: Computer
  
  required init(computer: Computer) {
    self.computer = computer

    super.init(frame: .zero)
    
    contentHorizontalAlignment = .left
    setTitleColor(UIColor.blue, for: .normal)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
