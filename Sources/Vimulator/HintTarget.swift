#if targetEnvironment(simulator)
import UIKit

struct HintTarget {
  let element: NSObject
  let hint: String

  @discardableResult
  func activate() -> Bool {
    // Text inputs need becomeFirstResponder — accessibilityActivate() alone
    // doesn't reliably trigger keyboard input in SwiftUI.
    if tryFocusTextInput() { return true }
    if element.accessibilityActivate() { return true }
    return fallbackActivate()
  }

  /// Hit-test the element's frame and walk up the hierarchy looking for a
  /// UITextField or UITextView, then call becomeFirstResponder().
  private func tryFocusTextInput() -> Bool {
    let frame = element.accessibilityFrame
    guard frame != .zero, let window = keyWindow() else { return false }
    let localPoint = window.convert(CGPoint(x: frame.midX, y: frame.midY), from: nil)
    guard let hit = window.hitTest(localPoint, with: nil) else { return false }

    var view: UIView? = hit
    while let v = view {
      if (v is UITextField || v is UITextView), let responder = v as? UIResponder {
        responder.becomeFirstResponder()
        return true
      }
      view = v.superview
    }
    return false
  }

  private func fallbackActivate() -> Bool {
    let frame = element.accessibilityFrame
    guard frame != .zero, let window = keyWindow() else { return false }
    let localPoint = window.convert(CGPoint(x: frame.midX, y: frame.midY), from: nil)
    guard let hit = window.hitTest(localPoint, with: nil) else { return false }

    var v: UIView? = hit
    while let current = v {
      if let control = current as? UIControl, control.isEnabled {
        control.sendActions(for: .touchUpInside)
        return true
      }
      v = current.superview
    }
    return false
  }

  private func keyWindow() -> UIWindow? {
    UIApplication.shared.keyWindowInConnectedScenes
  }
}
#endif
