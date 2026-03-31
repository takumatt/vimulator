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
    case "1", "2", "3", "4", "5":
      if let index = Int(char), let tbc = tabBarController() {
        let target = index - 1
        if target < tbc.viewControllers?.count ?? 0 {
          tbc.selectedIndex = target
        }
      }
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
    handleHintInput(char, onMatch: { $0.activate() })
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

  // MARK: - Scroll hint mode

  private func handleScrollHintKey(_ char: String) {
    handleHintInput(char, onMatch: { target in
      if let sv = target.element as? UIScrollView {
        ScrollController.shared.lock(to: sv)
      }
    })
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
    deactivate()
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
    let margin = SearchBar.margin
    let barWidth = window.bounds.width - margin * 2
    let barY = window.bounds.height - window.safeAreaInsets.bottom - SearchBar.height - margin
    searchBar.frame = CGRect(x: margin, y: barY, width: barWidth, height: SearchBar.height)
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
    deactivate()
    searchBarWindow?.isHidden = true
    searchBarWindow?.subviews.forEach { $0.removeFromSuperview() }
    searchBarWindow = nil
  }

  // MARK: - Helpers

  private func deactivate() {
    mode = .normal
    typedChars = ""
    currentHints = []
    overlay.hide()
  }

  /// Shared key handler for hint and scrollHint modes.
  /// Filters by prefix; calls `onMatch` and deactivates when exactly one hint is fully typed.
  private func handleHintInput(_ char: String, onMatch: (HintTarget) -> Void) {
    if char == "\u{1B}" { deactivate(); return }

    typedChars += char.lowercased()
    let matches = currentHints.filter { $0.hint.hasPrefix(typedChars) }

    if matches.isEmpty { deactivate(); return }

    if matches.count == 1 && matches[0].hint == typedChars {
      onMatch(matches[0])
      deactivate()
      return
    }

    overlay.highlight(matching: typedChars)
  }

  private func keyWindow() -> UIWindow? {
    UIApplication.shared.keyWindowInConnectedScenes
  }

  private func tabBarController() -> UITabBarController? {
    guard let root = keyWindow()?.rootViewController else { return nil }
    return findTabBarController(in: root)
  }

  private func findTabBarController(in vc: UIViewController) -> UITabBarController? {
    if let tbc = vc as? UITabBarController { return tbc }
    for child in vc.children {
      if let found = findTabBarController(in: child) { return found }
    }
    if let presented = vc.presentedViewController {
      return findTabBarController(in: presented)
    }
    return nil
  }
}
#endif
