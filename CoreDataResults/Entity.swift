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

    public var count: Int {
        return Query(context: context, request: fetchRequest).count
    }

    public func findOrCreate(matching predicate: NSPredicate, setup: ((E) -> E) = { $0 }) -> E {
        guard let entity: E = Query(context: context, request: fetchRequest).matching(predicate: predicate).first else {
            return create(setup: setup)
        }

        return entity
    }

    public func create(setup: (E) -> E) -> E {
        return setup(E(context: context))
    }

    public func matching(predicate: NSPredicate) -> Query<E> {
        return Query(context: context, request: fetchRequest).matching(predicate: predicate)
    }

    public func sorted(with descriptors: [NSSortDescriptor]) -> Query<E> {
        return Query(context: context, request: fetchRequest).sorted(with: descriptors)
    }
}



