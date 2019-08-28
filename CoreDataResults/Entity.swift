//
//  Entity.swift
//  CoreDataResults
//
//  Created by Andrew Tetlaw on 27/6/17.
//  Copyright © 2017 Dexagogo. All rights reserved.
//

//
//  CoreDataResult.swift
//  Olmy
//
//  Created by Andrew Tetlaw on 9/5/17.
//  Copyright © 2017 Dexagogo. All rights reserved.
//

import CoreData

public struct Entity<E: NSManagedObject> {

    public var fetchRequest: NSFetchRequest<E>  {
        return NSFetchRequest<E>(entityName: E.entityName())
    }

    let context: NSManagedObjectContext

    public init(context moc: NSManagedObjectContext) {
        context = moc
    }

    public var all: [E] {
        return Query(context: context, request: fetchRequest).managedObjects
    }

    public var allObjectIDs: [NSManagedObjectID] {
        return Query(context: context, request: fetchRequest).managedObjectIDs
    }

    public var count: Int {
        return Query(context: context, request: fetchRequest).count
    }

    public func make(_ setup: (E) -> Void) -> E {
        let entity = E(context: context)
        setup(entity)
        return entity
    }

    public func matching(_ id: NSManagedObjectID) -> E? {
        return context.object(with: id) as? E
    }

    public func matching(predicate: NSPredicate) -> Query<E> {
        return Query(context: context, request: fetchRequest).matching(predicate: predicate)
    }

    public func sorted(with descriptors: [NSSortDescriptor]) -> Query<E> {
        return Query(context: context, request: fetchRequest).sorted(with: descriptors)
    }
}



