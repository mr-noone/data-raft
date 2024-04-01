import Foundation

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
import CommonCrypto
#elseif os(Linux)
import Cryptor
#endif

extension String {
  var md5: [UInt8] {
    #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
    let context = UnsafeMutablePointer<CC_MD5_CTX>.allocate(capacity: 1)
    var digest = Array<UInt8>(repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
    
    CC_MD5_Init(context)
    CC_MD5_Update(context, self, CC_LONG(lengthOfBytes(using: .utf8)))
    CC_MD5_Final(&digest, context)
    
    context.deallocate()
    
    return digest
    #elseif os(Linux)
    return Digest(using: .md5).update(string: self)!.final()
    #endif
  }
}
