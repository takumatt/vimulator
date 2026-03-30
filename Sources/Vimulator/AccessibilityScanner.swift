#if targetEnvironment(simulator)
import UIKit

enum AccessibilityScanner {
  private static let interactiveTraits: UIAccessibilityTraits = [
    .button, .link, .adjustable, .keyboardKey, .searchField
  ]

  static func scan(in root: UIView) -> [NSObject] {
    var results: [NSObject] = []
    var stack: [NSObject] = [root]

    while let node = stack.popLast() {
      // If the node is itself interactive, collect it without recursing further
      if node.isAccessibilityElement {
        if isInteractive(node) {
          results.append(node)
        }
        // Non-interactive accessibility element (e.g. label, image): skip
        continue
      }

      // If the node exposes custom accessibility children (e.g. SwiftUI containers),
      // recurse into those
      if let children = node.accessibilityElements as? [NSObject], !children.isEmpty {
        stack.append(contentsOf: children.reversed())
        continue
      }

      // UIView with no custom accessibility children: recurse into subviews
      if let view = node as? UIView {
        for subview in view.subviews.reversed() where !subview.isHidden && subview.alpha > 0 {
          stack.append(subview)
        }
      }
    }

    return results
  }

  private static func isInteractive(_ element: NSObject) -> Bool {
    if let control = element as? UIControl { return control.isEnabled }
    return !element.accessibilityTraits.intersection(interactiveTraits).isEmpty
  }
}
#endif
