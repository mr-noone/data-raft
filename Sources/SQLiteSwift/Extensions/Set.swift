import Foundation

extension Set {
    /// Removes all elements from the set that satisfy the given predicate.
    ///
    /// - Parameter shouldBeRemoved: A closure that takes an element of the set as its argument
    ///   and returns a Boolean value indicating whether the element should be removed from the set.
    @inlinable
    mutating func removeAll(where shouldBeRemoved: (Element) throws -> Bool) rethrows {
        for element in self {
            if try shouldBeRemoved(element) {
                remove(element)
            }
        }
    }
}
