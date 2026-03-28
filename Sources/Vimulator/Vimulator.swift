#if targetEnvironment(simulator)
import UIKit

/// Entry point. Call `Vimulator.shared.install()` once in your app delegate or @main.
public final class Vimulator {
    public static let shared = Vimulator()

    private let overlay = HintOverlay()
    private var isHintModeActive = false
    private var typedChars = ""
    private var currentHints: [HintTarget] = []

    private init() {}

    /// Install Vimulator. Must be called after the key window is ready.
    public func install() {
        KeyboardMonitor.shared.onKeyDown = { [weak self] char in
            self?.handleKey(char)
        }
    }

    private func handleKey(_ char: String) {
        if !isHintModeActive {
            if char == "f" {
                activateHintMode()
            }
            return
        }

        if char == "\u{1B}" { // Escape
            deactivateHintMode()
            return
        }

        typedChars += char.lowercased()

        let matches = currentHints.filter { $0.hint.hasPrefix(typedChars) }

        if matches.isEmpty {
            deactivateHintMode()
            return
        }

        if matches.count == 1 && matches[0].hint == typedChars {
            matches[0].element.accessibilityActivate()
            deactivateHintMode()
            return
        }

        overlay.highlight(matching: typedChars)
    }

    private func activateHintMode() {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .last(where: { $0.isKeyWindow }) else { return }

        let elements = AccessibilityScanner.scan(in: window)
        let hints = HintGenerator.generate(count: elements.count)
        currentHints = zip(elements, hints).map { HintTarget(element: $0.0, hint: $0.1) }

        isHintModeActive = true
        typedChars = ""
        overlay.show(hints: currentHints, in: window)
    }

    private func deactivateHintMode() {
        isHintModeActive = false
        typedChars = ""
        currentHints = []
        overlay.hide()
    }
}

struct HintTarget {
    let element: UIAccessibilityElement_
    let hint: String
}

/// Protocol-like alias so we can work with both UIView and UIAccessibilityElement
typealias UIAccessibilityElement_ = NSObject
#endif
