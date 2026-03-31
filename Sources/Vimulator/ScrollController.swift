#if targetEnvironment(simulator)
import UIKit

final class ScrollController {
  static let shared = ScrollController()

  /// Points per second when holding a scroll key.
  private let velocity: CGFloat = 600

  private var displayLink: CADisplayLink?
  private var direction: Direction?
  private var lastTimestamp: CFTimeInterval = 0
  private(set) var lockedScrollView: UIScrollView?

  private init() {}

  func lock(to scrollView: UIScrollView) {
    lockedScrollView = scrollView
  }

  func unlock() {
    lockedScrollView = nil
  }

  enum Direction { case up, down, left, right }

  // MARK: - Public

  func scrollToTop() {
    guard let sv = findScrollView() else { return }
    let top = CGPoint(x: sv.contentOffset.x, y: -sv.adjustedContentInset.top)
    sv.setContentOffset(top, animated: true)
  }

  func scrollToBottom() {
    guard let sv = findScrollView() else { return }
    let inset = sv.adjustedContentInset
    let maxY = sv.contentSize.height - sv.bounds.height + inset.bottom
    let bottom = CGPoint(x: sv.contentOffset.x, y: max(-inset.top, maxY))
    sv.setContentOffset(bottom, animated: true)
  }

  func start(direction: Direction) {
    stop()
    self.direction = direction
    let link = CADisplayLink(target: self, selector: #selector(tick(_:)))
    link.add(to: .main, forMode: .common)
    displayLink = link
  }

  func stop() {
    displayLink?.invalidate()
    displayLink = nil
    direction = nil
    lastTimestamp = 0
  }

  // MARK: - Private

  @objc private func tick(_ link: CADisplayLink) {
    guard let direction else { return }

    let dt: CGFloat
    if lastTimestamp == 0 {
      dt = 0
    } else {
      dt = link.timestamp - lastTimestamp
    }
    lastTimestamp = link.timestamp

    guard dt > 0, let scrollView = findScrollView() else { return }

    let step = velocity * dt
    let offset = scrollView.contentOffset
    let new: CGPoint
    switch direction {
    case .down:  new = CGPoint(x: offset.x, y: offset.y + step)
    case .up:  new = CGPoint(x: offset.x, y: offset.y - step)
    case .right: new = CGPoint(x: offset.x + step, y: offset.y)
    case .left:  new = CGPoint(x: offset.x - step, y: offset.y)
    }

    scrollView.setContentOffset(clamped(new, in: scrollView), animated: false)
  }

  // MARK: - Scroll view discovery

  private func findScrollView() -> UIScrollView? {
    if let locked = lockedScrollView { return locked }
    guard let window = keyWindow() else { return nil }
    return largestScrollView(in: window)
  }

  private func largestScrollView(in window: UIWindow) -> UIScrollView? {
    ScrollViewScanner.scan(in: window)
      .max { $0.bounds.width * $0.bounds.height < $1.bounds.width * $1.bounds.height }
  }

  private func clamped(_ offset: CGPoint, in sv: UIScrollView) -> CGPoint {
    let inset = sv.adjustedContentInset
    let minX = -inset.left
    let minY = -inset.top
    let maxX = max(minX, sv.contentSize.width  - sv.bounds.width  + inset.right)
    let maxY = max(minY, sv.contentSize.height - sv.bounds.height + inset.bottom)
    return CGPoint(
      x: min(max(minX, offset.x), maxX),
      y: min(max(minY, offset.y), maxY)
    )
  }

  private func keyWindow() -> UIWindow? {
    UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .last { $0.isKeyWindow }
  }
}
#endif
