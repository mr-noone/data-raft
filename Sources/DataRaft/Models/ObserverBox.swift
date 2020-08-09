import Foundation

final class ObserverBox {
  private weak var weak: TransactionObserver?
  private var strong: TransactionObserver?
  
  var unbox: TransactionObserver? {
    return strong ?? weak
  }
  
  init(weak: TransactionObserver) {
    self.weak = weak
  }
  
  init(strong: TransactionObserver) {
    self.strong = strong
  }
}
