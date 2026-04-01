#if targetEnvironment(simulator)
import UIKit

public enum HintTheme {
  case vimium
  case glass(tinted: UIColor = UIColor(red: 1.0, green: 0.96, blue: 0.4, alpha: 0.35))
  case simple

  var style: HintLabelStyle {
    switch self {
    case .vimium:
      return HintLabelStyle(
        backgroundColor: UIColor(red: 1.0, green: 0.96, blue: 0.4, alpha: 0.92),
        borderColor: UIColor(white: 0, alpha: 0.25),
        borderWidth: 0.5,
        cornerRadius: 3,
        textColor: .black,
        matchedPrefixColor: .systemRed,
        font: .monospacedSystemFont(ofSize: 11, weight: .bold),
        padding: 3
      )
    case .glass(let tinted):
      return HintLabelStyle(
        backgroundColor: .clear,
        useGlass: true,
        glassTintColor: tinted,
        useBlur: true,
        blurStyle: .systemUltraThinMaterial,
        borderColor: UIColor(white: 1, alpha: 0.25),
        borderWidth: 0.5,
        cornerRadius: 8,
        textColor: .label,
        matchedPrefixColor: .systemBlue,
        font: .monospacedSystemFont(ofSize: 11, weight: .semibold),
        padding: 5
      )
    case .simple:
      return HintLabelStyle(
        backgroundColor: .systemBackground,
        borderColor: .separator,
        borderWidth: 1,
        cornerRadius: 4,
        textColor: .label,
        matchedPrefixColor: .systemOrange,
        font: .monospacedSystemFont(ofSize: 11, weight: .medium),
        padding: 3
      )
    }
  }
}
#endif
