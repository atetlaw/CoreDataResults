//
//  QueryResult.swift
//  CoreDataResults
//
//  Created by Andrew Tetlaw on 31/3/18.
//  Copyright © 2018 Dexagogo. All rights reserved.
//

import Foundation
import CoreData

public enum QueryResult<E: NSManagedObject> {
    case managedObjects([E])
    case error(Error?)
}
