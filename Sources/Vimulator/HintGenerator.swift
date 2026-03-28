#if targetEnvironment(simulator)
enum HintGenerator {
  private static let chars = Array("asdfghjklqwertyuiopzxcvbnm")

  /// Generate `count` unique hint strings (e.g. "a", "s", ..., "as", "ad", ...)
  static func generate(count: Int) -> [String] {
    (0..<count).map { bijectiveBase($0) }
  }

  /// Bijective base-k numeration: 0→"a", 1→"s", ..., 25→"m", 26→"aa", ...
  private static func bijectiveBase(_ n: Int) -> String {
    let base = chars.count
    var n = n + 1
    var result = ""
    while n > 0 {
      n -= 1
      result = String(chars[n % base]) + result
      n /= base
    }
    return result
  }
}
#endif
