#if targetEnvironment(simulator)
import UIKit

public enum SearchTheme {
  case glass(tint: UIColor = .clear)
  case simple

  var useGlass: Bool {
    if case .glass = self { return true }
    return false
  }

  var glassTint: UIColor {
    if case .glass(let tint) = self { return tint }
    return .clear
  }

  var backgroundColor: UIColor {
    switch self {
    case .glass:  return .clear
    case .simple: return UIColor.systemBackground.withAlphaComponent(0.95)
    }
  }

  var textColor: UIColor { .label }
}
#endif
