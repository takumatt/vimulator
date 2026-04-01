#if targetEnvironment(simulator)
import UIKit

final class SearchBar: UIView {
  static let height: CGFloat = 52
  static let margin: CGFloat = 16

  private let icon = UILabel()
  private let queryLabel = UILabel()
  private var backgroundView: UIView?

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder: NSCoder) { fatalError() }

  private func setup() {
    backgroundColor = .clear
    layer.cornerRadius = SearchBar.height / 2
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOpacity = 0.15
    layer.shadowRadius = 8
    layer.shadowOffset = CGSize(width: 0, height: -2)

    icon.text = "/"
    icon.font = .monospacedSystemFont(ofSize: 16, weight: .bold)
    icon.sizeToFit()

    queryLabel.font = .monospacedSystemFont(ofSize: 16, weight: .regular)
    queryLabel.text = ""

    [icon, queryLabel].forEach { addSubview($0) }
    apply(theme: .glass())
  }

  func apply(theme: SearchTheme) {
    backgroundView?.removeFromSuperview()
    let bg: UIView

    if theme.useGlass, #available(iOS 26, *) {
      let effect = UIGlassEffect()
      if theme.glassTint != .clear { effect.tintColor = theme.glassTint }
      let v = UIVisualEffectView(effect: effect)
      v.clipsToBounds = true
      bg = v
    } else {
      let v = UIView()
      v.backgroundColor = theme.backgroundColor
      bg = v
    }

    bg.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    bg.layer.cornerRadius = SearchBar.height / 2
    insertSubview(bg, at: 0)
    backgroundView = bg

    icon.textColor = theme.textColor.withAlphaComponent(0.5)
    queryLabel.textColor = theme.textColor
  }

  func update(query: String) {
    queryLabel.text = query.isEmpty ? "type to search..." : query
    queryLabel.alpha = query.isEmpty ? 0.4 : 1.0
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    let padding: CGFloat = 24
    icon.frame.origin = CGPoint(x: padding, y: (bounds.height - icon.bounds.height) / 2)
    queryLabel.frame = CGRect(
      x: icon.frame.maxX + 8,
      y: 0,
      width: bounds.width - icon.frame.maxX - 8 - padding,
      height: bounds.height
    )
  }
}
#endif
