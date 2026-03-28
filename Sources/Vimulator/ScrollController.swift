#if targetEnvironment(simulator)
import UIKit

enum ScrollController {
    static let step: CGFloat = 120

    static func scroll(direction: Direction) {
        guard let scrollView = findScrollView() else { return }
        let offset = scrollView.contentOffset
        let new: CGPoint

        switch direction {
        case .down:  new = CGPoint(x: offset.x, y: offset.y + step)
        case .up:    new = CGPoint(x: offset.x, y: offset.y - step)
        case .right: new = CGPoint(x: offset.x + step, y: offset.y)
        case .left:  new = CGPoint(x: offset.x - step, y: offset.y)
        }

        scrollView.setContentOffset(clamped(new, in: scrollView), animated: true)
    }

    enum Direction { case up, down, left, right }

    // MARK: - Private

    /// Find the most relevant scroll view:
    /// 1. Walk up from the first responder
    /// 2. Fall back to hit-testing the screen center
    /// 3. Fall back to the deepest scroll view in the window
    private static func findScrollView() -> UIScrollView? {
        guard let window = keyWindow() else { return nil }

        if let responder = UIResponder.currentFirstResponder as? UIView,
           let sv = firstScrollView(from: responder) {
            return sv
        }

        let center = CGPoint(x: window.bounds.midX, y: window.bounds.midY)
        if let hit = window.hitTest(center, with: nil),
           let sv = firstScrollView(from: hit) {
            return sv
        }

        return deepestScrollView(in: window)
    }

    private static func firstScrollView(from view: UIView) -> UIScrollView? {
        var v: UIView? = view
        while let current = v {
            if let sv = current as? UIScrollView, sv.isScrollEnabled { return sv }
            v = current.superview
        }
        return nil
    }

    private static func deepestScrollView(in view: UIView) -> UIScrollView? {
        for subview in view.subviews.reversed() {
            if let found = deepestScrollView(in: subview) { return found }
        }
        if let sv = view as? UIScrollView, sv.isScrollEnabled { return sv }
        return nil
    }

    private static func clamped(_ offset: CGPoint, in sv: UIScrollView) -> CGPoint {
        let maxX = max(0, sv.contentSize.width - sv.bounds.width + sv.contentInset.right)
        let maxY = max(0, sv.contentSize.height - sv.bounds.height + sv.contentInset.bottom)
        return CGPoint(
            x: min(max(-sv.contentInset.left, offset.x), maxX),
            y: min(max(-sv.contentInset.top, offset.y), maxY)
        )
    }

    private static func keyWindow() -> UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .last { $0.isKeyWindow }
    }
}
#endif
