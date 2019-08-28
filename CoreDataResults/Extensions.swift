//
//  Extensions.swift
//  Olmy
//
//  Created by Andrew Tetlaw on 9/5/17.
//  Copyright © 2017 Dexagogo. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    public func entity<E>() -> Entity<E> {  
        return Entity<E>(context: self)
    }

    public func perform<R>(query: @escaping @autoclosure () -> R, completion: @escaping (R) -> Void) {
        perform { completion(query()) }
    }
}

extension NSManagedObject {
    open class func entityName() -> String {
        return "\(self)"
    }

    class func predicateWithObjectIDs(objectIDs: [NSManagedObjectID]) -> NSPredicate {
        return NSPredicate(format: "self IN %@", argumentArray: [objectIDs])
    }
}

public func &&(lhs: NSPredicate, rhs: NSPredicate) -> NSPredicate {
    return NSCompoundPredicate(andPredicateWithSubpredicates: [lhs, rhs])
}

public func ||(lhs: NSPredicate, rhs: NSPredicate) -> NSPredicate {
    return NSCompoundPredicate(orPredicateWithSubpredicates: [lhs, rhs])
}

public prefix func !(_ predicate: NSPredicate) -> NSPredicate {
    return  NSCompoundPredicate(notPredicateWithSubpredicate: predicate)
}
