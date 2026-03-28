#if targetEnvironment(simulator)
import UIKit

enum AccessibilityScanner {
    static func scan(in root: UIView) -> [NSObject] {
        var results: [NSObject] = []
        walk(root, into: &results)
        return results
    }

    private static func walk(_ node: NSObject, into results: inout [NSObject]) {
        // If the node exposes custom accessibility children, recurse into those
        if let children = node.accessibilityElements as? [NSObject], !children.isEmpty {
            for child in children {
                walk(child, into: &results)
            }
            return
        }

        // Leaf: if interactive, collect it
        if node.isAccessibilityElement {
            if isInteractive(node) {
                results.append(node)
            }
            return
        }

        // UIView with no custom accessibility children: recurse into subviews
        if let view = node as? UIView {
            for subview in view.subviews where !subview.isHidden && subview.alpha > 0 {
                walk(subview, into: &results)
            }
        }
    }

    private static func isInteractive(_ element: NSObject) -> Bool {
        if let control = element as? UIControl { return control.isEnabled }
        let traits = element.accessibilityTraits
        let interactive: UIAccessibilityTraits = [.button, .link, .adjustable, .keyboardKey, .searchField]
        return !traits.intersection(interactive).isEmpty
    }
}
#endif
