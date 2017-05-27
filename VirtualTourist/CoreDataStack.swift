//
//  CoreDataStack.swift
//  VirtualTourist
//
//  Created by Edvin Lellhame on 4/18/17.
//  Copyright © 2017 Edvin Lellhame. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
	private let modelName: String
	
	init(modelName: String) {
		self.modelName = modelName
	}
	
	private lazy var storeContainer: NSPersistentContainer = {
		let container = NSPersistentContainer(name: self.modelName)
		container.loadPersistentStores { (_, error) in
			if let error = error as NSError? {
				print("Unresolved error \(error), \(error.userInfo)")
			}
		}
		return container
	}()
	
	lazy var managedContext: NSManagedObjectContext = {
		return self.storeContainer.viewContext
	}()
	
	func saveContext() {
		guard managedContext.hasChanges else { return }
		
		do {
			try managedContext.save()
		} catch let error as NSError {
			print("Unresolved error \(error), \(error.userInfo)")
		}
	}
}
