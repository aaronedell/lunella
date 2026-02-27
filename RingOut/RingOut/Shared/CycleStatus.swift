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

    /// Gradient color that shifts as the phase progresses
    /// IN: bright green → muted green/yellow-green as approaching day 21
    /// OUT: bright red → darker red as approaching day 7
    var gradientColor: Color {
        switch self {
        case .inPhase(let day):
            // day 0-20 (21 days total)
            // Start bright green, shift toward yellow-green
            let progress = Double(day) / 20.0 // 0.0 to 1.0
            let hue = 0.33 - (progress * 0.08) // Green (0.33) shifting toward yellow-green (0.25)
            let saturation = 0.8 - (progress * 0.2) // Slightly less saturated
            let brightness = 0.75 - (progress * 0.15) // Slightly dimmer
            return Color(hue: hue, saturation: saturation, brightness: brightness)
        case .outPhase(let day):
            // day 0-6 (7 days total)
            // Start bright blue, shift toward darker blue
            let progress = Double(day) / 6.0 // 0.0 to 1.0
            let hue = 0.67 // Blue stays blue
            let saturation = 0.85 - (progress * 0.1) // Slightly less saturated
            let brightness = 0.8 - (progress * 0.25) // Dimmer as approaching end
            return Color(hue: hue, saturation: saturation, brightness: brightness)
        case .notConfigured:
            return .gray
        }
    }

    /// Optional subtitle text
    var subtitleText: String {
        switch self {
        case .inPhase(let day):
            return "Day \(day + 1) of 21"
        case .outPhase(let day):
            return "Day \(day + 1) of 7"
        case .notConfigured:
            return "Open app to configure"
        }
    }
}
