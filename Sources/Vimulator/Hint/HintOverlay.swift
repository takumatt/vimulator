#if targetEnvironment(simulator)
import UIKit

final class HintOverlay {
  private var window: UIWindow?
  private var labels: [String: HintLabel] = [:]        // hint string → label
  private var highlights: [String: UIView] = [:]       // hint string → highlight frame

  enum LabelPosition { case topLeading, center }

  func show(hints: [HintTarget], config: HintOverlayConfiguration, in keyWindow: UIWindow) {
    if window != nil { hide() }
    let style = config.style
    let overlayEffect = config.overlayEffect
    let animation = config.animation
    let labelPosition = config.labelPosition
    let showAreaHighlight = config.showAreaHighlight
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

      // Area highlight
      if showAreaHighlight {
        let highlight = UIView(frame: frame)
        highlight.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.15)
        highlight.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.5).cgColor
        highlight.layer.borderWidth = 1.5
        highlight.layer.cornerRadius = 8
        highlight.isUserInteractionEnabled = false
        container.addSubview(highlight)
      }

      let label = HintLabel(hint: target.hint, style: style)
      switch labelPosition {
      case .topLeading:
        label.center = CGPoint(x: frame.minX + label.bounds.width / 2, y: frame.minY + label.bounds.height / 2 + 2)
      case .center:
        label.center = CGPoint(x: frame.midX, y: frame.midY)
      }
      container.addSubview(label)
      labels[target.hint] = label
    }

    switch animation {
    case .none:
      overlayWindow.isHidden = false
    case .fade(let duration):
      overlayWindow.alpha = 0
      overlayWindow.isHidden = false
      UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut) {
        overlayWindow.alpha = 1
      }
    }
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

  /// Show only hints whose keys are in `visibleHints`, hide the rest.
  func filterByHints(_ visibleHints: Set<String>) {
    for (hint, label) in labels {
      label.alpha = visibleHints.contains(hint) ? 1.0 : 0.0
    }
  }

  /// Show overlay effect + element frame highlights for search mode (no hint labels).
  func showSearch(targets: [HintTarget], effect: HintOverlayEffect, animation: HintAppearAnimation, in keyWindow: UIWindow) {
    if window != nil { hide() }
    let overlayWindow = makeWindow(over: keyWindow)
    window = overlayWindow

    switch effect {
    case .none: break
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

    highlights = [:]
    for target in targets {
      guard let frame = target.element.accessibilityFrame(in: overlayWindow) else { continue }
      let v = UIView(frame: frame)
      v.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.12)
      v.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.5).cgColor
      v.layer.borderWidth = 1.5
      v.layer.cornerRadius = 8
      v.isUserInteractionEnabled = false
      container.addSubview(v)
      highlights[target.hint] = v
    }

    switch animation {
    case .none:
      overlayWindow.isHidden = false
    case .fade(let duration):
      overlayWindow.alpha = 0
      overlayWindow.isHidden = false
      UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut) {
        overlayWindow.alpha = 1
      }
    }
  }

  /// Update which element highlights are visible based on search matches.
  func updateSearchHighlights(visibleHints: Set<String>) {
    for (hint, view) in highlights {
      view.alpha = visibleHints.contains(hint) ? 1.0 : 0.0
    }
  }

  func hide() {
    window?.isHidden = true
    window?.subviews.forEach { $0.removeFromSuperview() }
    window = nil
    labels = [:]
    highlights = [:]
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
