#if targetEnvironment(simulator)
import XCTest
import UIKit
@testable import Vimulator

final class AccessibilityScannerTests: XCTestCase {

  // MARK: - Correctness

  func testFindsInteractiveElements() {
    let root = UIView(frame: CGRect(x: 0, y: 0, width: 375, height: 812))
    for i in 0..<5 {
      root.addSubview(makeButton(y: i * 50))
    }
    let results = AccessibilityScanner.scan(in: root)
    XCTAssertEqual(results.count, 5)
  }

  func testIgnoresHiddenViews() {
    let root = UIView(frame: CGRect(x: 0, y: 0, width: 375, height: 812))
    root.addSubview(makeButton(y: 0))
    let hidden = makeButton(y: 50)
    hidden.isHidden = true
    root.addSubview(hidden)
    let results = AccessibilityScanner.scan(in: root)
    XCTAssertEqual(results.count, 1)
  }

  func testIgnoresTransparentViews() {
    let root = UIView(frame: CGRect(x: 0, y: 0, width: 375, height: 812))
    root.addSubview(makeButton(y: 0))
    let transparent = makeButton(y: 50)
    transparent.alpha = 0
    root.addSubview(transparent)
    let results = AccessibilityScanner.scan(in: root)
    XCTAssertEqual(results.count, 1)
  }

  func testIgnoresNonInteractiveElements() {
    let root = UIView(frame: CGRect(x: 0, y: 0, width: 375, height: 812))
    let label = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
    label.isAccessibilityElement = true
    label.accessibilityTraits = .staticText
    root.addSubview(label)
    root.addSubview(makeButton(y: 30))
    let results = AccessibilityScanner.scan(in: root)
    XCTAssertEqual(results.count, 1)
  }

  func testFindsElementsWithCustomAccessibilityActivation() {
    let root = UIView(frame: CGRect(x: 0, y: 0, width: 375, height: 812))
    let activatable = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
    activatable.isAccessibilityElement = true
    activatable.accessibilityTraits = .staticText
    activatable.accessibilityLabel = "Search"
    activatable.accessibilityRespondsToUserInteraction = true
    root.addSubview(activatable)

    let results = AccessibilityScanner.scan(in: root)

    XCTAssertEqual(results.count, 1)
    XCTAssertTrue(results.first === activatable)
  }

  func testIgnoresCustomAccessibilityActivationWithoutLabel() {
    let root = UIView(frame: CGRect(x: 0, y: 0, width: 375, height: 812))
    let activatable = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
    activatable.isAccessibilityElement = true
    activatable.accessibilityTraits = .staticText
    activatable.accessibilityRespondsToUserInteraction = true
    root.addSubview(activatable)

    let results = AccessibilityScanner.scan(in: root)

    XCTAssertTrue(results.isEmpty)
  }

  // MARK: - Performance

  func testPerformanceShallowHierarchy() {
    let root = makeHierarchy(depth: 1, breadth: 50)
    measure(metrics: [XCTClockMetric()]) {
      _ = AccessibilityScanner.scan(in: root)
    }
  }

  func testPerformanceDeepHierarchy() {
    let root = makeHierarchy(depth: 8, breadth: 4)
    measure(metrics: [XCTClockMetric()]) {
      _ = AccessibilityScanner.scan(in: root)
    }
  }

  func testPerformanceWideHierarchy() {
    let root = makeHierarchy(depth: 3, breadth: 10)
    measure(metrics: [XCTClockMetric()]) {
      _ = AccessibilityScanner.scan(in: root)
    }
  }

  // MARK: - Helpers

  /// UIView with .button trait — works without a window unlike UIButton in iOS 26
  private func makeButton(y: Int) -> UIView {
    let v = UIView(frame: CGRect(x: 0, y: y, width: 100, height: 44))
    v.isAccessibilityElement = true
    v.accessibilityTraits = .button
    return v
  }

  /// Build a view tree: each non-leaf node has `breadth` UIView children,
  /// leaf nodes are accessibility buttons.
  private func makeHierarchy(depth: Int, breadth: Int) -> UIView {
    let root = UIView(frame: CGRect(x: 0, y: 0, width: 375, height: 812))
    addChildren(to: root, depth: depth, breadth: breadth)
    return root
  }

  private func addChildren(to parent: UIView, depth: Int, breadth: Int) {
    for i in 0..<breadth {
      let frame = CGRect(x: 0, y: i * 10, width: 100, height: 44)
      if depth <= 1 {
        parent.addSubview(makeButton(y: i * 10))
      } else {
        let container = UIView(frame: frame)
        parent.addSubview(container)
        addChildren(to: container, depth: depth - 1, breadth: breadth)
      }
    }
  }
}
#endif
