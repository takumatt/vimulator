#if targetEnvironment(simulator)
import UIKit

/// Entry point. Call `Vimulator.shared.install()` once in your app delegate or @main.
public final class Vimulator {
    public static let shared = Vimulator()

    public var style: HintLabelStyle = .vimium

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
        KeyboardMonitor.shared.onKeyUp = { [weak self] char in
            self?.handleKeyUp(char)
        }
    }

    private func handleKey(_ char: String) {
        if !isHintModeActive {
            if let direction = scrollDirection(for: char) {
                ScrollController.shared.start(direction: direction)
                return
            }
            if char == "f" { activateHintMode() }
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
            matches[0].activate()
            deactivateHintMode()
            return
        }

        overlay.highlight(matching: typedChars)
    }

    private func handleKeyUp(_ char: String) {
        if scrollDirection(for: char) != nil {
            ScrollController.shared.stop()
        }
    }

    private func scrollDirection(for char: String) -> ScrollController.Direction? {
        switch char {
        case "j": return .down
        case "k": return .up
        case "h": return .left
        case "l": return .right
        default:  return nil
        }
    }

    // MARK: - Hint mode

    private func activateHintMode() {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .last(where: { $0.isKeyWindow }) else { return }

        let elements = AccessibilityScanner.scan(in: window)
        let hints = HintGenerator.generate(count: elements.count)
        currentHints = zip(elements, hints).map { HintTarget(element: $0, hint: $1) }

        isHintModeActive = true
        typedChars = ""
        overlay.show(hints: currentHints, style: style, in: window)
    }

    private func deactivateHintMode() {
        isHintModeActive = false
        typedChars = ""
        currentHints = []
        overlay.hide()
    }
}
#endif
