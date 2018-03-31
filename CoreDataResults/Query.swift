//
//  Query.swift
//  CoreDataResults
//
//  Created by Andrew Tetlaw on 27/6/17.
//  Copyright © 2017 Dexagogo. All rights reserved.
//

import CoreData

public struct Query<E: NSManagedObject> {
    var fetch: NSFetchRequest<E>
    let managedObjectContext: NSManagedObjectContext

    public var fetchRequest: NSFetchRequest<E> {
        return fetch
    }

    public init(context moc: NSManagedObjectContext, request: NSFetchRequest<E>) {
        managedObjectContext = moc
        fetch = request
    }

    public func sorted(with descriptors: [NSSortDescriptor]) -> Query<E> {
        fetch.sortDescriptors = descriptors
        return self
    }

    public func matching(predicate: NSPredicate) -> Query<E> {
        guard let existing = fetch.predicate else {
            fetch.predicate = predicate
            return self
        }

        fetch.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [existing, predicate])
        return self
    }

    public func or(matching: NSPredicate) -> Query<E> {
        guard let existing = fetch.predicate else {
            fetch.predicate = matching
            return self
        }
        fetch.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [existing, matching])
        return self
    }

    func limit(to limit: Int) -> Query<E> {
        fetch.fetchLimit = limit
        return self
    }

    func offset(by offset: Int) -> Query<E> {
        fetch.fetchOffset = offset
        return self
    }

    func batch(size: Int) -> Query<E> {
        fetch.fetchBatchSize = size
        return self
    }

    //MARK: Getting the results
    public var managedObjects: [E] {
        return (try? asManagedObjects()) ?? []
    }

    public var count: Int {
        return (try? resultCount()) ?? 0
    }

    public var first: E? {
        return (try? firstResult()) ?? nil
    }

    public var managedObjectIDs: [NSManagedObjectID] {
        return (try? asManagedObjectIDs()) ?? []
    }

    public var dictionaries: [NSDictionary] {
        return (try? asDictionaries()) ?? []
    }

    public func asManagedObjects() throws -> [E] {
        fetch.resultType = .managedObjectResultType
        return try  managedObjectContext.fetch(fetch)
    }

    public func asAsyncManagedObjects(handler: @escaping (QueryResult<E>) -> ()) {
        fetch.resultType = .managedObjectResultType
        let asyncFetch = NSAsynchronousFetchRequest(fetchRequest: fetch) { (fetchResult) in
            guard let result = fetchResult.finalResult else {
                handler(QueryResult<E>.error(fetchResult.operationError))
                return
            }

            handler(QueryResult<E>.managedObjects(result))
        }

        do {
            let _ = try managedObjectContext.execute(asyncFetch)

        } catch (let error) {
            handler(QueryResult<E>.error(error))
        }
    }

    public func firstResult() throws -> E? {
        if let predicate = fetch.predicate, let result = findRegistered(matching: predicate) {
            return result
        }

        fetch.resultType = .managedObjectResultType
        fetch.fetchLimit = 1
        return try managedObjectContext.fetch(fetch).first
    }

    public func resultCount() throws -> Int {
        return try managedObjectContext.count(for: fetch)
    }

    public func asManagedObjectIDs() throws -> [NSManagedObjectID] {
        return try managedObjectContext.fetch(asManagedObjectID(request: fetch))
    }

    public func asDictionaries() throws -> [NSDictionary] {
        fetch.resultType = .managedObjectIDResultType
        return try managedObjectContext.fetch(asDictionary(request: fetch))
    }

    public func findRegistered(matching predicate: NSPredicate) -> E? {
        for object in managedObjectContext.registeredObjects where !object.isFault {
            guard let result = object as? E, predicate.evaluate(with: result) else { continue }
            return result
        }
        return nil
    }

    func asManagedObjectID(request: NSFetchRequest<E>) -> NSFetchRequest<NSManagedObjectID> {
        let fetch: NSFetchRequest<NSManagedObjectID> = transform(request: request)
        fetch.resultType = .managedObjectIDResultType
        return fetch
    }

    func asDictionary(request: NSFetchRequest<E>) -> NSFetchRequest<NSDictionary> {
        let fetch: NSFetchRequest<NSDictionary> = transform(request: request)
        fetch.resultType = .dictionaryResultType
        return fetch
    }

    func transform<R: NSFetchRequestResult>(request: NSFetchRequest<E>) -> NSFetchRequest<R> {
        let fetch = NSFetchRequest<R>(entityName: E.entityName())
        fetch.predicate = request.predicate
        fetch.resultType = .managedObjectIDResultType

        fetch.fetchBatchSize = request.fetchBatchSize
        fetch.fetchLimit = request.fetchLimit
        fetch.fetchOffset = request.fetchOffset

        fetch.sortDescriptors = request.sortDescriptors

        // FIXME: ...many more needed here

        return fetch
    }
}


