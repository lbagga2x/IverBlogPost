//
//  DataModel.swift
//  Drug Shortages Canada
//
//  Created by Wes Goodhoofd on 2016-10-25.
//  Copyright © 2016 Iversoft Solutions Inc. All rights reserved.
//

import Foundation
import Alamofire
import CoreData

private let _sharedModel = DataModel()

class DataModel: NSObject {
    var managedContext: NSManagedObjectContext?
    
    override init() {
        super.init()
        
        managedContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    }
    
    class func sharedModel() -> DataModel {
        return _sharedModel
    }
    
    // MARK: - Core Data stack
    /* convenience methods for handling common Core Data tasks */
    func getObject(entityName: String, withId: Int, property:String) -> NSManagedObject? {
        var predicate:NSPredicate
        
        let predicateFormat = String(format: "%@ = %%d", arguments: [property])
        predicate = NSPredicate(format: predicateFormat, withId)
        
        let results = retrieveEntities(entityName, predicate: predicate, sort: nil)
        if results.count > 0 {
            return results.first
        } else {
            return nil
        }
    }
    
    func retrieveEntities(_ name:String, predicate:NSPredicate?, sort:NSSortDescriptor?, limit:Int = 0) -> Array<NSManagedObject> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: name)
        if predicate != nil {
            fetchRequest.predicate = predicate
        }
        
        if limit > 0 {
            fetchRequest.fetchLimit = limit
        }
        
        if sort != nil {
            var sortArray = Array<NSSortDescriptor>()
            sortArray.append(sort!)
            fetchRequest.sortDescriptors = sortArray
        }
        
        do {
            let fetchResults = try managedContext!.fetch(fetchRequest) as! [NSManagedObject]
            return fetchResults
        } catch let error as NSError {
            Constants.debugPrint("Could not fetch \(error), \(error.userInfo)")
            return []
        }
    }
    
    func countEntities(_ name:String) -> Int {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: name)
        request.includesSubentities = false
        
        do {
            let count = try managedContext!.count(for: request)
            return count
        } catch let error as NSError {
            Constants.debugPrintFormat("count error %@", values: error.localizedDescription)
            return 0
        }
    }
    
    func createEntity(_ name:String) -> NSManagedObject {
        return NSEntityDescription.insertNewObject(forEntityName: name, into: managedContext!)
    }
    
    func saveContext() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.saveContext()
    }
}
