import SwiftUI

/// Represents the current status in the cycle
enum CycleStatus {
    case inPhase(dayInPhase: Int)  // Days 7-27 of cycle (21 days total)
    case outPhase(dayInPhase: Int) // Days 0-6 of cycle (7 days total)
    case notConfigured             // No start date set

    /// The text to display in the widget
    var displayText: String {
        switch self {
        case .inPhase:
            return "IN"
        case .outPhase:
            return "OUT"
        case .notConfigured:
            return "SET DATE"
        }
    }

    /// The border color for the widget
    var borderColor: Color {
        switch self {
        case .inPhase:
            return .green
        case .outPhase:
            return .blue
        case .notConfigured:
            return .gray
        }
    }

    /// Optional subtitle text
    var subtitleText: String {
        switch self {
        case .inPhase(let day):
            return "IN phase • Day \(day + 1) of 21"
        case .outPhase(let day):
            return "OUT phase • Day \(day + 1) of 7"
        case .notConfigured:
            return "Open app to configure"
        }
    }
}
