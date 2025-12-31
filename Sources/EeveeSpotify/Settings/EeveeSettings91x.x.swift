import Orion
import SwiftUI
import UIKit

// Settings integration for 9.1.x - uses shake gesture instead of hooking settings classes
struct V91SettingsIntegrationGroup: HookGroup { }

// Hook UIApplication to detect shake gesture
class UIApplicationShakeGestureHook: ClassHook<UIApplication> {
    typealias Group = V91SettingsIntegrationGroup
    
    func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            // Show version info alert when device is shaken
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first,
                  let rootViewController = window.rootViewController else {
                orig.motionEnded(motion, with: event)
                return
            }
            
            // Find the top-most view controller
            var topController = rootViewController
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            let alert = UIAlertController(
                title: "🎵 EeveeSpotify",
                message: """
                Tweak Version: \(EeveeSpotify.version)
                Spotify Version: \(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)
                
                ⚠️ Limited functionality on Spotify 9.1.x:
                • Premium patching: ✓ Active
                • Lyrics: ✗ Not available
                • Full settings: ✗ Not available
                
                Shake device to see this info anytime!
                """,
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            
            alert.addAction(UIAlertAction(title: "Open GitHub", style: .default) { _ in
                if let url = URL(string: "https://github.com/Meeep1/EeveeSpotifyReborn2-swift") {
                    UIApplication.shared.open(url)
                }
            })
            
            topController.present(alert, animated: true)
            return
        }
        
        orig.motionEnded(motion, with: event)
    }
}
