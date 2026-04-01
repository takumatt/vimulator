#if targetEnvironment(simulator)
import UIKit

public enum SearchTheme {
  case glass
  case simple

  var useGlass: Bool {
    if case .glass = self { return true }
    return false
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
