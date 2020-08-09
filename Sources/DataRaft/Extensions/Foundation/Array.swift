import Foundation

extension Array {
  subscript(ifExists index: Int) -> Element? {
    if count > index {
      return self[index]
    } else {
      return nil
    }
  }
}
