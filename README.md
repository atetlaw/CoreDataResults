# CoreDataResults

This one is a bit of an experiment for creating a useful CoreData API that abstracts all the boilerplate for fetching. Most I've seen start from the entity and require the managed object context as an argument. 

This one starts with the managed object context as the focus of making queries. You add extensions for your managed object subclasses, in this case `Page` and `Topic`:

```swift
extension NSManagedObjectContext {
    var pages: Entity<Page> {
        return entity()
    }

    var topics: Entity<Topic> {
        return entity()
    }
}
```

Then, if you use `viewContext` from `NSManagedContainer` you can call:

```swift
viewContext.pages.sorted(with: [NSSortDescriptor(key: "title", ascending: true)]).managedObjects
```

`viewContext.pages.sorted(with: [NSSortDescriptor(key: "title", ascending: true)])` sets up the fetch request parameters, and then calling `.managedObjects` is when the fetch is actually made. Alternatively you can call `.managedObjectIDs`, `.count`, `.dictionaries`, even `.first`.

There are some shortcuts like:

`viewContext.pages.all` that will return all pages as `[Page]`, and `viewContext.pages.count` that will return an integer.

You can stack all the api calls for finer control over querying:

```swift
viewContext.pages.matching(predicate: NSPredicate(format: "%K == %@", "topic", "General"))
                 .sorted(with: [NSSortDescriptor(key: "created", ascending: true)])
                 .limit(to: 10)
                 .managedObjects
```
                       
It's not really complete yet, just trying it out to see where it goes, and if the API feels natural. There's an early attempt at supporting sync queries as well.
