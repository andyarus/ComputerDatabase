//
//  DatabaseService.swift
//  ComputerDatabase
//
//  Created by Andrei Coder on 08/11/2019.
//  Copyright © 2019 yaav. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class DatabaseService: DatabaseServiceProtocol {
  
  /// Create data
  func createData(for computer: Computer) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    let managedObjectContext = appDelegate.persistentContainer.viewContext
    
    guard let computerEntityDescription = NSEntityDescription.entity(forEntityName: "ComputerEntity", in: managedObjectContext),
      let computerManagedObject = NSManagedObject(entity: computerEntityDescription, insertInto: managedObjectContext) as? ComputerEntity else { return }
    
    computerManagedObject.id = Int32(computer.id)
    computerManagedObject.name = computer.name
    computerManagedObject.introduced = computer.introduced
    computerManagedObject.discounted = computer.discounted
    computerManagedObject.descr = computer.description
  
//    let image = computer.image?.jpegData(compressionQuality: 1.0) : nil
//    computerManagedObject.image = image
    
    if let company = computer.company,
      let companyEntityDescription = NSEntityDescription.entity(forEntityName: "CompanyEntity", in: managedObjectContext),
      let companyManagedObject = NSManagedObject(entity: companyEntityDescription, insertInto: managedObjectContext) as? CompanyEntity {
      companyManagedObject.id = Int32(company.id)
      companyManagedObject.name = company.name
      companyManagedObject.computer = computerManagedObject
    }
    if let similarItems = computer.similarItems,
      let similarItemEntityDescription = NSEntityDescription.entity(forEntityName: "ComputerItemSimilarEntity", in: managedObjectContext) {
      for similarItem in similarItems {
        guard let similarItemManagedObject = NSManagedObject(entity: similarItemEntityDescription, insertInto: managedObjectContext) as? ComputerItemSimilarEntity else { return }
        similarItemManagedObject.id = Int32(similarItem.id)
        similarItemManagedObject.name = similarItem.name
        similarItemManagedObject.computer = computerManagedObject
      }
    }
    
    do {
      try managedObjectContext.save()
    } catch {
      print("Data creation failed: \(error)")
    }
  }
  
  /// Retrieve data
  func retrieveData() -> [Computer] {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
    let managedContext = appDelegate.persistentContainer.viewContext

    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ComputerEntity")

    var entities: [Computer] = []
    
    do {
      let result = try managedContext.fetch(fetchRequest)
      print(result)
      guard let managedObjects = result as? [ComputerEntity] else { return [] }
      
      for managedObject in managedObjects {
        guard let computerName = managedObject.name else { continue }
        
        var company: Company?
        if let companyEntity = managedObject.company,
          let name = companyEntity.name {
          company = Company(id: Int(companyEntity.id),
                                name: name)
        }
        
        var similarItems: [ComputerItemSimilar] = []
        if let similarItemsEntities = managedObject.similarItems?.allObjects as? [ComputerItemSimilarEntity] {
          for similarItemEntity in similarItemsEntities {
            guard let name = similarItemEntity.name else { continue }
            let similarItem = ComputerItemSimilar(id: Int(similarItemEntity.id),
                                                  name: name)
            similarItems.append(similarItem)
          }
        }

        let retrievedEntity = Computer(id: Int(managedObject.id),
                                       name: computerName,
                                       introduced: managedObject.introduced,
                                       discounted: managedObject.discounted,
                                       imageUrl: nil,
                                       company: company,
                                       description: managedObject.descr,
                                       similarItems: similarItems.isEmpty ? nil : similarItems)
        
        entities.append(retrievedEntity)
      }
    } catch {
      print("Data retrieving failed: \(error)")
    }

    return entities
  }
  
  /// Update data
  func updateData(for computer: Computer) {
  }
  
  /// Remove all data
  func deleteData() {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    let managedObjectContext = appDelegate.persistentContainer.viewContext

    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ComputerEntity")

    do {
      let result = try managedObjectContext.fetch(fetchRequest)
      guard let managedObjects = result as? [NSManagedObject] else { return }

      for managedObject in managedObjects {
        managedObjectContext.delete(managedObject)
      }

      try managedObjectContext.save()
    } catch {
      print("Data deletion failed: \(error)")
    }
  }
  
}
