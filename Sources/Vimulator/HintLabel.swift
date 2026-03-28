#if targetEnvironment(simulator)
import UIKit

final class HintLabel: UIView {
    private let label = UILabel()
    private var blurView: UIVisualEffectView?
    private let hint: String
    private let style: HintLabelStyle

    init(hint: String, style: HintLabelStyle) {
        self.hint = hint
        self.style = style
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        layer.cornerRadius = style.cornerRadius
        layer.borderWidth = style.borderWidth
        layer.borderColor = style.borderColor.cgColor
        layer.masksToBounds = true

        if style.useBlur {
            let blur = UIVisualEffectView(effect: UIBlurEffect(style: style.blurStyle))
            blur.frame = bounds
            blur.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            addSubview(blur)
            blurView = blur
        } else {
            backgroundColor = style.backgroundColor
        }

        label.font = style.font
        label.textColor = style.textColor
        label.text = hint
        label.sizeToFit()

        let p = style.padding
        let size = CGSize(width: label.bounds.width + p * 2, height: label.bounds.height + p * 2)
        bounds = CGRect(origin: .zero, size: size)
        label.center = CGPoint(x: bounds.midX, y: bounds.midY)
        addSubview(label)

        // Re-frame blur after bounds are set
        blurView?.frame = bounds
    }

    func setMatched(prefix: String) {
        alpha = 1.0
        let remaining = String(hint.dropFirst(prefix.count))
        let attributed = NSMutableAttributedString(
            string: prefix,
            attributes: [.foregroundColor: style.matchedPrefixColor, .font: style.font]
        )
        attributed.append(NSAttributedString(
            string: remaining,
            attributes: [.foregroundColor: style.textColor, .font: style.font]
        ))
        label.attributedText = attributed
    }
}
#endif
