#if targetEnvironment(simulator)
import ObjectiveC.runtime
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
    if !element.accessibilityTraits.intersection(interactiveTraits).isEmpty {
      return true
    }
    return hasCustomAccessibilityActivation(element)
  }

  private static func hasCustomAccessibilityActivation(_ element: NSObject) -> Bool {
    let selector = NSSelectorFromString("accessibilityActivate")
    let baselineClass: AnyClass = baselineClass(for: element)

    var currentClass: AnyClass? = object_getClass(element)
    while let current = currentClass, current != baselineClass {
      guard
        let method = class_getInstanceMethod(current, selector),
        let superclass = class_getSuperclass(current),
        let superMethod = class_getInstanceMethod(superclass, selector)
      else {
        currentClass = class_getSuperclass(current)
        continue
      }

      if method_getImplementation(method) != method_getImplementation(superMethod) {
        return true
      }

      currentClass = superclass
    }

    return false
  }

  private static func baselineClass(for element: NSObject) -> AnyClass {
    if element is UIView {
      return UIView.self
    }

    if let accessibilityElementClass = NSClassFromString("UIAccessibilityElement"),
       element.isKind(of: accessibilityElementClass) {
      return accessibilityElementClass
    }

    return NSObject.self
  }
}
#endif
