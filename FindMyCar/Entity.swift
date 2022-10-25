//
//  Entity.swift
//  FindMyCar
//
//  Created by mert polat on 19.10.2022.
//

import Foundation
import CoreData

@objc(Entity)


public class Entity : NSManagedObject{
    
}


extension Entity {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Entity> {
        
        
        return NSFetchRequest<Entity>(entityName: "Entity")
    }
    
    @NSManaged public var image: NSData?
    
    
}
