import Foundation

extension Set {
    @inlinable mutating func removeAll(where shouldBeRemoved: (Element) throws -> Bool) rethrows {
        guard let index = try firstIndex(where: shouldBeRemoved) else { return }
        remove(at: index)
    }
}
