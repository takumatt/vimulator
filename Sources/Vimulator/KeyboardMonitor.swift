#if targetEnvironment(simulator)
import UIKit

/// Monitors hardware keyboard input globally by swizzling UIApplication.sendEvent.
final class KeyboardMonitor {
    static let shared = KeyboardMonitor()
    var onKeyDown: ((String) -> Void)?

    private init() {
        swizzleSendEvent()
    }

    private func swizzleSendEvent() {
        let cls = UIApplication.self
        let original = class_getInstanceMethod(cls, #selector(UIApplication.sendEvent(_:)))!
        let swizzled = class_getInstanceMethod(cls, #selector(UIApplication.vim_sendEvent(_:)))!
        method_exchangeImplementations(original, swizzled)
    }
}

extension UIApplication {
    @objc func vim_sendEvent(_ event: UIEvent) {
        // Call original (swizzled, so this calls the real sendEvent)
        vim_sendEvent(event)

        guard let pressesEvent = event as? UIPressesEvent else { return }

        // While a text input is active, let UIKit handle all keys except Escape
        if let responder = UIResponder.currentFirstResponder, responder is UITextInput {
            for press in pressesEvent.allPresses where press.phase == .began {
                if press.key?.keyCode == .keyboardEscape {
                    responder.resignFirstResponder()
                }
            }
            return
        }

        for press in pressesEvent.allPresses where press.phase == .began {
            guard let key = press.key else { continue }
            let char = key.characters
            guard !char.isEmpty else { continue }
            KeyboardMonitor.shared.onKeyDown?(char)
        }
    }
}
#endif
