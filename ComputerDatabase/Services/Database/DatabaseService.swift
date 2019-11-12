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
    computerManagedObject.imageUrl = computer.imageUrl
    computerManagedObject.image = computer.imageData
    computerManagedObject.descr = computer.description
    computerManagedObject.updatedDate = computer.updatedDate
    
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
    let managedObjectContext = appDelegate.persistentContainer.viewContext

    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ComputerEntity")

    var entities: [Computer] = []
    
    do {
      let result = try managedObjectContext.fetch(fetchRequest)
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
                                       imageUrl: managedObject.imageUrl,
                                       company: company,
                                       description: managedObject.descr,
                                       similarItems: similarItems.isEmpty ? nil : similarItems,
                                       imageData: managedObject.image,
                                       updatedDate: managedObject.updatedDate)
        
        entities.append(retrievedEntity)
      }
    } catch {
      print("Data retrieving failed: \(error)")
    }

    return entities
  }
  
  /// Retrieve data by key
  func retrieveData(by key: String) -> Computer? {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
    let managedObjectContext = appDelegate.persistentContainer.viewContext
    
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ComputerEntity")
    fetchRequest.predicate = NSPredicate(format: "id = %@", key)
    
    do {
      let result = try managedObjectContext.fetch(fetchRequest)
      guard let managedObjects = result as? [ComputerEntity],
        let managedObject = managedObjects.first else { return nil }

      guard let computerName = managedObject.name else { return nil }
      
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
                                     imageUrl: managedObject.imageUrl,
                                     company: company,
                                     description: managedObject.descr,
                                     similarItems: similarItems.isEmpty ? nil : similarItems,
                                     imageData: managedObject.image,
                                     updatedDate: managedObject.updatedDate)
      return retrievedEntity
    } catch {
      print("Data retrieving failed: \(error)")
    }
    
    return nil
  }
  
  /// Update data
  func updateData(for computer: Computer) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    let managedObjectContext = appDelegate.persistentContainer.viewContext
    
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ComputerEntity")
    fetchRequest.predicate = NSPredicate(format: "id = %@", String(computer.id))
    
    do {
      let result = try managedObjectContext.fetch(fetchRequest)
      guard let managedObjects = result as? [ComputerEntity],
        let computerManagedObject = managedObjects.first else { return }
      
      //computerManagedObject.id = Int32(computer.id) // don't update id
      computerManagedObject.name = computer.name
      computerManagedObject.introduced = computer.introduced
      computerManagedObject.discounted = computer.discounted
      computerManagedObject.imageUrl = computer.imageUrl
      //computerManagedObject.image = computer.imageData // updated in special method
      computerManagedObject.descr = computer.description
      computerManagedObject.updatedDate?.computer = computer.updatedDate?.computer
      
      if let company = computer.company {
        computerManagedObject.company?.id = Int32(company.id)
        computerManagedObject.company?.name = company.name
        computerManagedObject.company?.computer = computerManagedObject
      }
      
      try managedObjectContext.save()
    } catch {
      print("Data updating failed: \(error)")
    }
  }
  
  /// Update data with similarItems
  func updateData(for id: Int, with similarItems: [ComputerItemSimilar]) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    let managedObjectContext = appDelegate.persistentContainer.viewContext
    
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ComputerEntity")
    fetchRequest.predicate = NSPredicate(format: "id = %@", String(id))
    
    do {
      let result = try managedObjectContext.fetch(fetchRequest)
      guard let managedObjects = result as? [ComputerEntity],
        let computerManagedObject = managedObjects.first else { return }
      
      computerManagedObject.updatedDate?.similarItems = Date()
      
      /// Clear saved entities
      if let similarItemsEntities = computerManagedObject.similarItems?.allObjects as? [ComputerItemSimilarEntity] {
        for similarItemEntity in similarItemsEntities {
          managedObjectContext.delete(similarItemEntity)
        }
      }
      /// Add new entities
      if let similarItemEntityDescription = NSEntityDescription.entity(forEntityName: "ComputerItemSimilarEntity", in: managedObjectContext) {
        for similarItem in similarItems {
          guard let similarItemManagedObject = NSManagedObject(entity: similarItemEntityDescription, insertInto: managedObjectContext) as? ComputerItemSimilarEntity else { return }
          similarItemManagedObject.id = Int32(similarItem.id)
          similarItemManagedObject.name = similarItem.name
          similarItemManagedObject.computer = computerManagedObject
        }
      }
      
      try managedObjectContext.save()
    } catch {
      print("Data updating failed: \(error)")
    }
  }
  
  /// Update data with imageData
  func updateData(for id: Int, with imageData: Data) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    let managedObjectContext = appDelegate.persistentContainer.viewContext
    
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ComputerEntity")
    fetchRequest.predicate = NSPredicate(format: "id = %@", String(id))
    
    do {
      let result = try managedObjectContext.fetch(fetchRequest)
      guard let managedObjects = result as? [ComputerEntity],
        let computerManagedObject = managedObjects.first else { return }
      
      computerManagedObject.image = imageData
      computerManagedObject.updatedDate?.image = Date()
      
      try managedObjectContext.save()
    } catch {
      print("Data updating failed: \(error)")
    }
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
