#if targetEnvironment(simulator)
import UIKit

final class SearchBar: UIView {
  static let height: CGFloat = 52
  static let margin: CGFloat = 16
  private let icon = UILabel()
  private let queryLabel = UILabel()

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

    let visualEffect: UIVisualEffectView
    if #available(iOS 26, *) {
      visualEffect = .init(effect: UIGlassEffect())
    } else {
      visualEffect = .init(effect: UIBlurEffect(style: .systemMaterial))
    }
    visualEffect.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    visualEffect.layer.cornerRadius = SearchBar.height / 2
    visualEffect.clipsToBounds = true
    insertSubview(visualEffect, at: 0)

    icon.text = "/"
    icon.font = .monospacedSystemFont(ofSize: 16, weight: .bold)
    icon.textColor = .secondaryLabel
    icon.sizeToFit()

    queryLabel.font = .monospacedSystemFont(ofSize: 16, weight: .regular)
    queryLabel.textColor = .label
    queryLabel.text = ""

    [icon, queryLabel].forEach { addSubview($0) }
  }

  func update(query: String) {
    queryLabel.text = query.isEmpty ? "type to search..." : query
    queryLabel.textColor = query.isEmpty ? .tertiaryLabel : .label
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
