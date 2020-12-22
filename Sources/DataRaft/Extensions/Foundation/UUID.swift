import Foundation
import CommonCrypto

extension UUID {
  init?(md5 bytes: [UInt8]) {
    guard
      bytes.count == CC_MD5_DIGEST_LENGTH
    else { return nil }
    
    var bytes = bytes
    bytes[6] &= 0x0f
    bytes[6] |= 0x30
    bytes[8] &= 0x3f
    bytes[8] |= 0x80
    
    let uuid = (
      bytes[0],  bytes[1],  bytes[2],  bytes[3],
      bytes[4],  bytes[5],  bytes[6],  bytes[7],
      bytes[8],  bytes[9],  bytes[10], bytes[11],
      bytes[12], bytes[13], bytes[14], bytes[15]
    )
    
    self.init(uuid: uuid)
  }
}
