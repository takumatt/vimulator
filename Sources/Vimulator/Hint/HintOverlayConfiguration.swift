#if targetEnvironment(simulator)
import UIKit

struct HintOverlayConfiguration {
  var style: HintLabelStyle
  var overlayEffect: HintOverlayEffect
  var animation: HintAppearAnimation
  var labelPosition: HintOverlay.LabelPosition
  var showAreaHighlight: Bool

  static func forElements(
    style: HintLabelStyle,
    overlayEffect: HintOverlayEffect,
    animation: HintAppearAnimation
  ) -> HintOverlayConfiguration {
    HintOverlayConfiguration(
      style: style,
      overlayEffect: overlayEffect,
      animation: animation,
      labelPosition: .topLeading,
      showAreaHighlight: false
    )
  }

  static func forScrollViews(
    style: HintLabelStyle,
    overlayEffect: HintOverlayEffect,
    animation: HintAppearAnimation
  ) -> HintOverlayConfiguration {
    HintOverlayConfiguration(
      style: style,
      overlayEffect: overlayEffect,
      animation: animation,
      labelPosition: .center,
      showAreaHighlight: true
    )
  }
}
#endif
