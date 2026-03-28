#if targetEnvironment(simulator)
import UIKit

public enum HintAppearAnimation {
  case none
  case fade(duration: TimeInterval = 0.15)
}
#endif
