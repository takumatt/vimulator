#if targetEnvironment(simulator)
import UIKit

final class HintOverlay {
    private var window: UIWindow?
    private var labels: [String: HintLabel] = [:]  // hint string → label

    func show(hints: [HintTarget], style: HintLabelStyle, overlayEffect: HintOverlayEffect, in keyWindow: UIWindow) {
        let overlayWindow = makeWindow(over: keyWindow)
        window = overlayWindow

        // Overlay effect (dim or blur)
        switch overlayEffect {
        case .none:
            break
        case .dim(let color):
            let dimView = UIView(frame: overlayWindow.bounds)
            dimView.backgroundColor = color
            dimView.isUserInteractionEnabled = false
            overlayWindow.addSubview(dimView)
        case .blur(let blurStyle, let opacity):
            let blurView = UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
            blurView.frame = overlayWindow.bounds
            blurView.alpha = opacity
            blurView.isUserInteractionEnabled = false
            overlayWindow.addSubview(blurView)
        }

        let container = UIView(frame: overlayWindow.bounds)
        container.isUserInteractionEnabled = false
        container.backgroundColor = .clear
        overlayWindow.addSubview(container)

        labels = [:]
        for target in hints {
            guard let frame = target.element.accessibilityFrame(in: overlayWindow) else { continue }
            let label = HintLabel(hint: target.hint, style: style)
            label.center = CGPoint(x: frame.minX + 2, y: frame.midY)
            container.addSubview(label)
            labels[target.hint] = label
        }

        overlayWindow.isHidden = false
    }

    func highlight(matching prefix: String) {
        for (hint, label) in labels {
            if hint.hasPrefix(prefix) {
                label.setMatched(prefix: prefix)
            } else {
                label.alpha = 0.25
            }
        }
    }

    func hide() {
        window?.isHidden = true
        window?.subviews.forEach { $0.removeFromSuperview() }
        window = nil
        labels = [:]
    }

    private func makeWindow(over keyWindow: UIWindow) -> UIWindow {
        let w: UIWindow
        if let scene = keyWindow.windowScene {
            w = UIWindow(windowScene: scene)
        } else {
            w = UIWindow(frame: keyWindow.bounds)
        }
        w.windowLevel = keyWindow.windowLevel + 1
        w.isUserInteractionEnabled = false
        w.backgroundColor = .clear
        w.isHidden = true
        return w
    }
}

private extension NSObject {
    /// Convert accessibilityFrame (screen coords) to the coordinate space of `window`.
    func accessibilityFrame(in window: UIWindow) -> CGRect? {
        let frame = self.accessibilityFrame
        guard frame != .zero else { return nil }
        return window.convert(frame, from: nil)
    }
}
#endif
