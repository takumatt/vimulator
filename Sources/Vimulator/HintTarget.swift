#if targetEnvironment(simulator)
import UIKit

struct HintTarget {
    let element: NSObject
    let hint: String

    /// Activate the element.
    /// 1. Try `accessibilityActivate()` (works for most UIKit / SwiftUI elements)
    /// 2. Fall back to `UIControl.sendActions(for: .touchUpInside)` via hit-test
    @discardableResult
    func activate() -> Bool {
        if element.accessibilityActivate() { return true }
        return fallbackActivate()
    }

    private func fallbackActivate() -> Bool {
        let frame = element.accessibilityFrame
        guard frame != .zero,
              let window = keyWindow() else { return false }

        let localPoint = window.convert(
            CGPoint(x: frame.midX, y: frame.midY),
            from: nil
        )

        guard let hit = window.hitTest(localPoint, with: nil) else { return false }

        if let control = closestControl(from: hit) {
            control.sendActions(for: .touchUpInside)
            return true
        }
        return false
    }

    private func closestControl(from view: UIView) -> UIControl? {
        var v: UIView? = view
        while let current = v {
            if let control = current as? UIControl, control.isEnabled { return control }
            v = current.superview
        }
        return nil
    }

    private func keyWindow() -> UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .last { $0.isKeyWindow }
    }
}
#endif
