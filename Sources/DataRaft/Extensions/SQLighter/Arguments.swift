import Foundation
import SQLighter

public extension Arguments {
  init(record: Record) {
    self.init(array: record.map { $0.value })
  }
}
