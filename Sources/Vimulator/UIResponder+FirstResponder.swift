#if targetEnvironment(simulator)
import UIKit

extension UIResponder {
    private static weak var _current: UIResponder?

    /// Returns the current first responder by walking the responder chain via sendAction.
    static var currentFirstResponder: UIResponder? {
        _current = nil
        UIApplication.shared.sendAction(#selector(_captureFirstResponder), to: nil, from: nil, for: nil)
        return _current
    }

    @objc private func _captureFirstResponder() {
        UIResponder._current = self
    }
}
#endif
