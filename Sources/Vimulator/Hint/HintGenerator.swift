#if targetEnvironment(simulator)
enum HintGenerator {
  private static let chars = Array("asdfghjklqwertyuiopzxcvbnm")

  /// Generate `count` unique hint strings with uniform length (e.g. "aa", "as", "ad", ...)
  static func generate(count: Int) -> [String] {
    guard count > 0 else { return [] }
    let length = requiredLength(for: count)
    return (0..<count).map { fixedLengthHint($0, length: length) }
  }

  /// Minimum hint length needed to represent `count` unique hints
  private static func requiredLength(for count: Int) -> Int {
    let base = chars.count
    var length = 1
    var capacity = base
    while capacity < count {
      length += 1
      capacity *= base
    }
    return length
  }

  /// Generate a fixed-length hint by treating `n` as a base-k number with zero-padding
  private static func fixedLengthHint(_ n: Int, length: Int) -> String {
    let base = chars.count
    var n = n
    var result = ""
    for _ in 0..<length {
      result = String(chars[n % base]) + result
      n /= base
    }
    return result
  }
}
#endif
