#if targetEnvironment(simulator)
import UIKit

/// Entry point. Call `Vimulator.shared.install()` once in your app delegate or @main.
public final class Vimulator {
  public static let shared = Vimulator()

  public var style: HintLabelStyle = .vimium
  public var overlayEffect: HintOverlayEffect = .none
  public var appearAnimation: HintAppearAnimation = .fade()
  public var hintKey: String = "f"

  private let overlay = HintOverlay()
  private var mode: Mode = .normal
  private var typedChars = ""
  private var currentHints: [HintTarget] = []

  // gg detection
  private var lastGTime: TimeInterval = 0
  private let ggInterval: TimeInterval = 0.4

  private enum Mode {
    case normal
    case hint       // f → element activation
    case scrollHint // F → scroll view selection
  }

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
    switch mode {
    case .normal:
      handleNormalKey(char)
    case .hint:
      handleHintKey(char)
    case .scrollHint:
      handleScrollHintKey(char)
    }
  }

  // MARK: - Normal mode

  private func handleNormalKey(_ char: String) {
    if let direction = scrollDirection(for: char) {
      ScrollController.shared.start(direction: direction)
      return
    }
    switch char {
    case hintKey:  activateHintMode()
    case "F":      activateScrollHintMode()
    case "g":
      let now = Date().timeIntervalSinceReferenceDate
      if now - lastGTime <= ggInterval {
        ScrollController.shared.scrollToTop()
        lastGTime = 0
      } else {
        lastGTime = now
      }
    case "G": ScrollController.shared.scrollToBottom()
    case "\u{1B}": // Escape releases scroll lock
      ScrollController.shared.unlock()
    default: break
    }
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

  // MARK: - Element hint mode

  private func handleHintKey(_ char: String) {
    if char == "\u{1B}" {
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

  private func activateHintMode() {
    guard let window = keyWindow() else { return }
    let elements = AccessibilityScanner.scan(in: window)
    let hints = HintGenerator.generate(count: elements.count)
    currentHints = zip(elements, hints).map { HintTarget(element: $0, hint: $1) }
    mode = .hint
    typedChars = ""
    overlay.show(hints: currentHints, style: style, overlayEffect: overlayEffect, animation: appearAnimation, in: window)
  }

  private func deactivateHintMode() {
    mode = .normal
    typedChars = ""
    currentHints = []
    overlay.hide()
  }

  // MARK: - Scroll hint mode

  private func handleScrollHintKey(_ char: String) {
    if char == "\u{1B}" {
      deactivateScrollHintMode()
      return
    }

    typedChars += char.lowercased()
    let matches = currentHints.filter { $0.hint.hasPrefix(typedChars) }

    if matches.isEmpty {
      deactivateScrollHintMode()
      return
    }

    if matches.count == 1 && matches[0].hint == typedChars {
      if let sv = matches[0].element as? UIScrollView {
        ScrollController.shared.lock(to: sv)
      }
      deactivateScrollHintMode()
      return
    }

    overlay.highlight(matching: typedChars)
  }

  private func activateScrollHintMode() {
    guard let window = keyWindow() else { return }
    let scrollViews = ScrollViewScanner.scan(in: window)
    guard !scrollViews.isEmpty else { return }
    let hints = HintGenerator.generate(count: scrollViews.count)
    currentHints = zip(scrollViews, hints).map { HintTarget(element: $0, hint: $1) }
    mode = .scrollHint
    typedChars = ""
    overlay.show(hints: currentHints, style: style, overlayEffect: overlayEffect, animation: appearAnimation, labelPosition: .center, showAreaHighlight: true, in: window)
  }

  private func deactivateScrollHintMode() {
    mode = .normal
    typedChars = ""
    currentHints = []
    overlay.hide()
  }

  // MARK: - Helpers

  private func keyWindow() -> UIWindow? {
    UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .last { $0.isKeyWindow }
  }
}
#endif
