import Orion
import SwiftUI
import UIKit

// Settings integration for 9.1.x - shows version banner on launch
struct V91SettingsIntegrationGroup: HookGroup { }

// Helper to show banner (not a hook method)
func showVersionBannerOnWindow(_ window: UIWindow) {
    // Create a banner view
    let banner = UIView(frame: CGRect(x: 20, y: -100, width: window.bounds.width - 40, height: 80))
    banner.backgroundColor = .systemGreen
    banner.layer.cornerRadius = 12
    banner.layer.shadowColor = UIColor.black.cgColor
    banner.layer.shadowOpacity = 0.3
    banner.layer.shadowOffset = CGSize(width: 0, height: 4)
    banner.layer.shadowRadius = 8
    
    let label = UILabel(frame: banner.bounds.insetBy(dx: 16, dy: 16))
    label.numberOfLines = 0
    label.textAlignment = .center
    label.textColor = .white
    label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
    label.text = """
    🎵 EeveeSpotify v\(EeveeSpotify.version)
    Spotify \(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)
    Limited 9.1.x mode - Premium patching active
    """
    banner.addSubview(label)
    
    window.addSubview(banner)
    
    // Animate in
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: []) {
        banner.frame.origin.y = 60
    } completion: { _ in
        // Animate out after 4 seconds
        UIView.animate(withDuration: 0.3, delay: 4.0, options: []) {
            banner.frame.origin.y = -100
        } completion: { _ in
            banner.removeFromSuperview()
        }
    }
    
    NSLog("[EeveeSpotify] Version banner shown")
}

// Hook UIWindow to show version banner when it becomes key
class UIWindowKeyHook: ClassHook<UIWindow> {
    typealias Group = V91SettingsIntegrationGroup
    
    func becomeKeyWindow() {
        orig.becomeKeyWindow()
        
        // Check if we've already shown banner for this version
        let lastShownVersion = UserDefaults.standard.string(forKey: "EeveeSpotify_LastBannerVersion")
        let currentVersion = EeveeSpotify.version
        
        guard lastShownVersion != currentVersion else {
            NSLog("[EeveeSpotify] Banner already shown for version \(currentVersion)")
            return
        }
        
        // Mark this version as shown
        UserDefaults.standard.set(currentVersion, forKey: "EeveeSpotify_LastBannerVersion")
        
        // Show banner after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            showVersionBannerOnWindow(self.target)
        }
    }
}
