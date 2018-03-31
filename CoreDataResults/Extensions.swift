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

extension NSPredicate {
    var not: NSPredicate {
        return NSCompoundPredicate(notPredicateWithSubpredicate: self)
    }

    func and(predicates: NSPredicate...) -> NSPredicate {
        return and(predicates: predicates)
    }

    func and(predicates: [NSPredicate]) -> NSPredicate {
        var allPredicates = [self]
        allPredicates.append(contentsOf: predicates)
        return NSCompoundPredicate(andPredicateWithSubpredicates: allPredicates)
    }

    func and(format: String, arguments: [AnyObject]? = nil) -> NSPredicate {
        return and(predicates: [NSPredicate(format: format, argumentArray: arguments)])
    }

    func or(predicates: NSPredicate...) -> NSPredicate {
        return or(predicates: predicates)
    }

    func or(predicates: [NSPredicate]) -> NSPredicate {
        var allPredicates = [self]
        allPredicates.append(contentsOf: predicates)
        return NSCompoundPredicate(orPredicateWithSubpredicates: allPredicates)
    }

    func or(format: String, arguments: [AnyObject]? = nil) -> NSPredicate {
        return or(predicates: [NSPredicate(format: format, argumentArray: arguments)])
    }
}
