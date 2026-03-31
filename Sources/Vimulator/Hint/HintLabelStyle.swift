#if targetEnvironment(simulator)
import UIKit

public struct HintLabelStyle {
  // Background
  public var backgroundColor: UIColor
  public var useGlass: Bool
  public var glassTintColor: UIColor
  public var useBlur: Bool
  public var blurStyle: UIBlurEffect.Style

  // Border
  public var borderColor: UIColor
  public var borderWidth: CGFloat

  // Corner
  public var cornerRadius: CGFloat

  // Text
  public var textColor: UIColor
  public var matchedPrefixColor: UIColor
  public var font: UIFont

  // Padding
  public var padding: CGFloat

  public init(
    backgroundColor: UIColor,
    useGlass: Bool = false,
    glassTintColor: UIColor = UIColor(red: 1.0, green: 0.96, blue: 0.4, alpha: 0.35),
    useBlur: Bool = false,
    blurStyle: UIBlurEffect.Style = .systemMaterial,
    borderColor: UIColor = .clear,
    borderWidth: CGFloat = 0,
    cornerRadius: CGFloat = 4,
    textColor: UIColor = .black,
    matchedPrefixColor: UIColor = .systemRed,
    font: UIFont = .monospacedSystemFont(ofSize: 11, weight: .bold),
    padding: CGFloat = 3
  ) {
    self.backgroundColor = backgroundColor
    self.useGlass = useGlass
    self.glassTintColor = glassTintColor
    self.useBlur = useBlur
    self.blurStyle = blurStyle
    self.borderColor = borderColor
    self.borderWidth = borderWidth
    self.cornerRadius = cornerRadius
    self.textColor = textColor
    self.matchedPrefixColor = matchedPrefixColor
    self.font = font
    self.padding = padding
  }
}

public extension HintLabelStyle {
  /// Classic Vimium-style yellow badge.
  static let vimium = HintLabelStyle(
    backgroundColor: UIColor(red: 1.0, green: 0.96, blue: 0.4, alpha: 0.92),
    borderColor: UIColor(white: 0, alpha: 0.25),
    borderWidth: 0.5,
    cornerRadius: 3,
    textColor: .black,
    matchedPrefixColor: .systemRed,
    font: .monospacedSystemFont(ofSize: 11, weight: .bold),
    padding: 3
  )

  /// Modern frosted glass with large corner radius.
  static let modern = HintLabelStyle(
    backgroundColor: .clear,
    useBlur: true,
    blurStyle: .systemUltraThinMaterial,
    borderColor: UIColor(white: 1, alpha: 0.3),
    borderWidth: 0.5,
    cornerRadius: 8,
    textColor: .label,
    matchedPrefixColor: .systemBlue,
    font: .monospacedSystemFont(ofSize: 11, weight: .semibold),
    padding: 5
  )

  /// Minimal outline-only badge.
  static let simple = HintLabelStyle(
    backgroundColor: UIColor.systemBackground.withAlphaComponent(0.85),
    borderColor: .separator,
    borderWidth: 1,
    cornerRadius: 2,
    textColor: .label,
    matchedPrefixColor: .systemOrange,
    font: .monospacedSystemFont(ofSize: 10, weight: .medium),
    padding: 2
  )

  /// Dark badge for light-colored UIs.
  static let dark = HintLabelStyle(
    backgroundColor: UIColor(white: 0.1, alpha: 0.9),
    borderColor: UIColor(white: 1, alpha: 0.15),
    borderWidth: 0.5,
    cornerRadius: 4,
    textColor: .white,
    matchedPrefixColor: UIColor(red: 1, green: 0.45, blue: 0.45, alpha: 1),
    font: .monospacedSystemFont(ofSize: 11, weight: .bold),
    padding: 3
  )

  /// Liquid Glass badge (iOS 26+, falls back to blur on earlier versions).
  static let glass = HintLabelStyle(
    backgroundColor: .clear,
    useGlass: true,
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

  /// System accent color badge.
  static let accent = HintLabelStyle(
    backgroundColor: .tintColor.withAlphaComponent(0.9),
    cornerRadius: 5,
    textColor: .white,
    matchedPrefixColor: UIColor(white: 1, alpha: 0.6),
    font: .monospacedSystemFont(ofSize: 11, weight: .bold),
    padding: 4
  )
}
#endif
