#if targetEnvironment(simulator)
import UIKit

public enum HintOverlayEffect {
    case none
    case dim(UIColor = UIColor(white: 0, alpha: 0.3))
    case blur(style: UIBlurEffect.Style = .systemUltraThinMaterial, opacity: CGFloat = 0.7)
}
#endif
