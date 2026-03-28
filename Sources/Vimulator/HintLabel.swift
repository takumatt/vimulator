#if targetEnvironment(simulator)
import UIKit

final class HintLabel: UIView {
    private let label = UILabel()
    private let hint: String

    init(hint: String) {
        self.hint = hint
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        backgroundColor = UIColor(red: 1.0, green: 0.96, blue: 0.4, alpha: 0.92)
        layer.cornerRadius = 3
        layer.borderWidth = 0.5
        layer.borderColor = UIColor(white: 0, alpha: 0.25).cgColor

        label.font = .monospacedSystemFont(ofSize: 11, weight: .bold)
        label.textColor = .black
        label.text = hint
        label.sizeToFit()

        let padding: CGFloat = 3
        let size = CGSize(width: label.bounds.width + padding * 2,
                         height: label.bounds.height + padding * 2)
        bounds = CGRect(origin: .zero, size: size)
        label.center = CGPoint(x: bounds.midX, y: bounds.midY)
        addSubview(label)
    }

    /// Visually separate the already-typed prefix from the remaining chars.
    func setMatched(prefix: String) {
        alpha = 1.0
        let remaining = String(hint.dropFirst(prefix.count))
        let attributed = NSMutableAttributedString(
            string: prefix,
            attributes: [.foregroundColor: UIColor.systemRed, .font: label.font!]
        )
        attributed.append(NSAttributedString(
            string: remaining,
            attributes: [.foregroundColor: UIColor.black, .font: label.font!]
        ))
        label.attributedText = attributed
    }
}
#endif
