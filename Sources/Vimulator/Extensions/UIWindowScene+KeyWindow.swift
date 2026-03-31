#if targetEnvironment(simulator)
import UIKit

extension UIApplication {
  var keyWindowInConnectedScenes: UIWindow? {
    connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .last { $0.isKeyWindow }
  }
}
#endif
