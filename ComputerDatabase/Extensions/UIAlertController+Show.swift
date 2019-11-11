//
//  UIAlertController+Show.swift
//  ComputerDatabase
//
//  Created by Andrei Coder on 11/11/2019.
//  Copyright © 2019 yaav. All rights reserved.
//

import Foundation
import UIKit

extension UIAlertController {
  
  func show(in vc: UIViewController) {
    self.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    vc.present(self, animated: true, completion: nil)
  }
  
}
