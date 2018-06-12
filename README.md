# DataRaft

DataRaft is a small Swift framework that makes it both easier to use Core Data.

## Installation

Installation through CocoaPods.

```ruby
platform :ios, '8.0'
use_frameworks!

target 'YourTarget' do
    pod 'DataRaft'
end
```

## Usage

At first, create and configure a DataRaft instance. Use method `configure(type:modelName:bundle:storePath:options:)` for stack configuration.

```swift
let db = DataRaft()
do {
    try db.configure(modelName: "Example")
} catch {
    fatalError(error.localizedDescription)
}
```

If configuration of the stack will take a lot of time (E.G.: migration from old database), use async configuration method `configureAsync(type:modelName:bundle:storePath:options:completion:)`.

```swift
let db = DataRaft()
db.configureAsync(type: .sqLite, modelName: "Example") { error in
    print(error)
}
```

For obtain of the NSManagedObjectContext instance use:

- `main()` for main context.
- `private()` for new private context.

Use next methods: `performOnMain(_:)`, `performOnPrivate(_:)` or their sync analogs `performAndWaitOnMain(_:)`, `performAndWaitOnPrivate(_:)` to handle your data.

```swift
db.performOnPrivate { context in
    do {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Contact")
        let contacts = try context.fetch(request)
    } catch {
        print(error)
    }
}
```

To fetch NSManagedObject instances use `fetch(predicate:sortDescriptors:)` or `fetch(predicate:sortedBy:ascending:)`.

```swift
db.performOnMain { context in
    do {
        let contacts: [Contact] = try context.fetch()
    } catch {
        print(error)
    }
}
```

To persist data in base, use `saveToStore()`.

```swift
db.performOnMain { context in
    do {
        let contacts: [Contact] = try context.fetch()
        contacts.first?.firstName = "John"
        try context.saveToStore()
    } catch {
        print(error)
    }
}
```

To create NSManagedObject instance use `new()`.

```swift
db.performOnMain { context in
    let contact: Contact = context.new()
}
```

## Core Data Concurrency Debugging

With iOS 8 and Yosemite, the Core Data framework supports concurrency debugging. It works by throwing an exception whenever your app accesses a managed context or managed object from the wrong dispath queue. To enable it, add `-com.apple.CoreData.ConcurrencyDebug 1` to arguments passed on launch for your scheme.

## License

MIT license. See the [LICENSE file](https://github.com/nullgr/data-raft/blob/master/LICENSE) for details.
