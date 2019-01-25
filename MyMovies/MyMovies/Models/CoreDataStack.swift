//
//  CoreDataStack.swift
//  MyMovies
//
//  Created by Iyin Raphael on 1/25/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class  CoreDataStack {
    
    static let shared = CoreDataStack()
    
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Movie")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error {
                NSLog("Error occured while loading Pesersistence: \(error)")
            }
        })
        return container
    }()
    
    var mainContext: NSManagedObjectContext{
        return container.viewContext
    }
    
}
