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
  private let searchBar = SearchBar()
  private var searchBarWindow: UIWindow?
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
    case search     // / → filter by accessibility label
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
    case .search:
      handleSearchKey(char)
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
    case "/":      activateSearchMode()
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
    overlay.show(hints: currentHints, config: .forElements(style: style, overlayEffect: overlayEffect, animation: appearAnimation), in: window)
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
    overlay.show(hints: currentHints, config: .forScrollViews(style: style, overlayEffect: overlayEffect, animation: appearAnimation), in: window)
  }

  private func deactivateScrollHintMode() {
    mode = .normal
    typedChars = ""
    currentHints = []
    overlay.hide()
  }

  // MARK: - Search mode

  private func handleSearchKey(_ char: String) {
    switch char {
    case "\u{1B}":
      deactivateSearchMode()
    case "\r", "\n":
      // Enter: activate first match
      let query = typedChars
      let matches = currentHints.filter { matchesQuery($0, query: query) }
      if let first = matches.first {
        first.activate()
      }
      deactivateSearchMode()
    case "\u{7F}":
      // Backspace
      if !typedChars.isEmpty {
        typedChars.removeLast()
      }
      applySearchFilter()
      searchBar.update(query: typedChars)
    default:
      typedChars += char
      applySearchFilter()
      searchBar.update(query: typedChars)
    }
  }

  private func matchesQuery(_ target: HintTarget, query: String) -> Bool {
    guard !query.isEmpty else { return true }
    return target.element.accessibilityLabel?.localizedCaseInsensitiveContains(query) == true
  }

  private func applySearchFilter() {
    let query = typedChars
    let matches = currentHints.filter { matchesQuery($0, query: query) }
    let visibleHints = Set(matches.map { $0.hint })
    overlay.filterByHints(visibleHints)

    if matches.count == 1 {
      matches[0].activate()
      deactivateSearchMode()
    }
  }

  private func activateSearchMode() {
    guard let window = keyWindow() else { return }
    let elements = AccessibilityScanner.scan(in: window)
    let hints = HintGenerator.generate(count: elements.count)
    currentHints = zip(elements, hints).map { HintTarget(element: $0, hint: $1) }
    mode = .search
    typedChars = ""

    overlay.show(hints: currentHints, config: .forElements(style: style, overlayEffect: overlayEffect, animation: appearAnimation), in: window)

    // Show search bar in a floating window
    let barHeight: CGFloat = 52
    let barMargin: CGFloat = 16
    let barWidth = window.bounds.width - barMargin * 2
    let barY = window.bounds.height - window.safeAreaInsets.bottom - barHeight - barMargin
    searchBar.frame = CGRect(x: barMargin, y: barY, width: barWidth, height: barHeight)
    searchBar.update(query: "")

    let w: UIWindow
    if let scene = window.windowScene {
      w = UIWindow(windowScene: scene)
    } else {
      w = UIWindow(frame: window.bounds)
    }
    w.windowLevel = window.windowLevel + 2
    w.isUserInteractionEnabled = false
    w.backgroundColor = .clear
    w.addSubview(searchBar)
    w.isHidden = false
    searchBarWindow = w
  }

  private func deactivateSearchMode() {
    mode = .normal
    typedChars = ""
    currentHints = []
    overlay.hide()
    searchBarWindow?.isHidden = true
    searchBarWindow?.subviews.forEach { $0.removeFromSuperview() }
    searchBarWindow = nil
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
