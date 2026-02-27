import Foundation

/// Shared constants for the app and widget
/// IMPORTANT: Change this App Group ID to match your own provisioning profile
enum AppConstants {
    /// The App Group identifier - must be configured in both app and widget targets
    /// To use your own:
    /// 1. Create an App Group in Apple Developer Portal
    /// 2. Enable App Groups capability in both targets
    /// 3. Replace this value with your App Group ID
    static let appGroupId = "group.com.example.InOutWidget"

    /// UserDefaults key for storing the cycle start date
    static let cycleStartDateKey = "cycleStartDate"
}
