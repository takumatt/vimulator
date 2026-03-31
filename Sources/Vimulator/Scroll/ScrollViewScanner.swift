#if targetEnvironment(simulator)
import UIKit

enum ScrollViewScanner {
  /// Collect all visible, scrollable UIScrollViews in the window.
  static func scan(in window: UIWindow) -> [UIScrollView] {
    var results: [UIScrollView] = []
    walk(window, into: &results)
    return results
  }

  private static func walk(_ view: UIView, into results: inout [UIScrollView]) {
    if let sv = view as? UIScrollView,
       sv.isScrollEnabled,
       !sv.isHidden,
       sv.alpha > 0,
       canScroll(sv) {
      results.append(sv)
    }
    for subview in view.subviews {
      walk(subview, into: &results)
    }
  }

  private static func canScroll(_ sv: UIScrollView) -> Bool {
    let inset = sv.adjustedContentInset
    let scrollableH = sv.contentSize.height + inset.top + inset.bottom > sv.bounds.height
    let scrollableW = sv.contentSize.width + inset.left + inset.right > sv.bounds.width
    return scrollableH || scrollableW
  }
}
#endif
