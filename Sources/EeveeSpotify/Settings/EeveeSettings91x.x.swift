import Orion
import SwiftUI
import UIKit

// Settings integration for 9.1.x - uses triple-tap on status bar area to show version info
struct V91SettingsIntegrationGroup: HookGroup { }

// Hook UIWindow to detect triple-tap on status bar area
class UIWindowTripleTapHook: ClassHook<UIWindow> {
    typealias Group = V91SettingsIntegrationGroup
    
    static var hasSetupGesture = false
    
    func didMoveToSuperview() {
        orig.didMoveToSuperview()
        
        // Only setup once
        guard !Self.hasSetupGesture, target.superview != nil else { return }
        Self.hasSetupGesture = true
        
        // Add a triple-tap gesture recognizer to the window
        let tripleTap = UITapGestureRecognizer(target: self, action: #selector(handleTripleTap(_:)))
        tripleTap.numberOfTapsRequired = 3
        target.addGestureRecognizer(tripleTap)
        
        NSLog("[EeveeSpotify] Triple-tap gesture added to UIWindow for version info")
    }
    
    @objc func handleTripleTap(_ gesture: UITapGestureRecognizer) {
        let tapLocation = gesture.location(in: target)
        
        // Only trigger if tapped in the top 60 points (status bar area)
        guard tapLocation.y < 60 else { return }
        
        // Find the top-most view controller
        guard var topController = target.rootViewController else { return }
        
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
            
            💡 Triple-tap the top of the screen to see this anytime!
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
        
        NSLog("[EeveeSpotify] Version info alert presented")
    }
}
