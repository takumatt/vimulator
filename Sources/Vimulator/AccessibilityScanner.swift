#if targetEnvironment(simulator)
import UIKit

enum AccessibilityScanner {
    /// Recursively walk the accessibility tree and return all interactive elements.
    static func scan(in root: UIView) -> [NSObject] {
        var results: [NSObject] = []
        walk(root, into: &results)
        return results
    }

    private static func walk(_ view: UIView, into results: inout [NSObject]) {
        // If the view provides custom accessibility elements, use those
        if let elements = view.accessibilityElements, !elements.isEmpty {
            for case let element as NSObject in elements {
                if isInteractive(element) {
                    results.append(element)
                } else if let container = element as? UIView {
                    walk(container, into: &results)
                }
            }
            return
        }

        if isInteractive(view) {
            results.append(view)
        }

        for subview in view.subviews where !subview.isHidden && subview.alpha > 0 {
            walk(subview, into: &results)
        }
    }

    private static func isInteractive(_ element: NSObject) -> Bool {
        guard element.isAccessibilityElement else { return false }
        let traits = element.accessibilityTraits
        let interactiveTraits: UIAccessibilityTraits = [
            .button, .link, .adjustable, .keyboardKey,
            .searchField, .image // image can be a button too via accessibilityActivate
        ]
        // Also include text fields and controls
        if let view = element as? UIControl { return view.isEnabled }
        return !traits.intersection(interactiveTraits).isEmpty
    }
}
#endif
