import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

/// A single entry for the widget timeline
struct CycleEntry: TimelineEntry {
    let date: Date
    let status: CycleStatus
}

// MARK: - Timeline Provider

/// Provides timeline entries for the widget
struct CycleTimelineProvider: TimelineProvider {

    /// Placeholder entry shown while loading
    func placeholder(in context: Context) -> CycleEntry {
        CycleEntry(date: Date(), status: .inPhase(dayInPhase: 0))
    }

    /// Snapshot for widget gallery preview
    func getSnapshot(in context: Context, completion: @escaping (CycleEntry) -> Void) {
        let status = CycleStatusCalculator.getCurrentStatus()
        let entry = CycleEntry(date: Date(), status: status)
        completion(entry)
    }

    /// Generate timeline entries for the next several days
    /// The widget will automatically update at midnight each day
    func getTimeline(in context: Context, completion: @escaping (Timeline<CycleEntry>) -> Void) {
        var entries: [CycleEntry] = []
        let calendar = Calendar.current

        // Generate entries for the next 7 days
        // Each entry is scheduled for midnight of that day
        for dayOffset in 0..<7 {
            guard let futureDate = calendar.date(byAdding: .day, value: dayOffset, to: Date()) else {
                continue
            }

            // Set to start of day (midnight)
            let startOfDay = calendar.startOfDay(for: futureDate)
            let status = CycleStatusCalculator.getStatus(for: startOfDay)
            let entry = CycleEntry(date: startOfDay, status: status)
            entries.append(entry)
        }

        // If no entries were created, add a default one
        if entries.isEmpty {
            entries.append(CycleEntry(date: Date(), status: .notConfigured))
        }

        // Request a new timeline after the last entry
        // This ensures the widget keeps updating even after 7 days
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

// MARK: - Widget View

/// The main view for the widget
struct CycleWidgetEntryView: View {
    var entry: CycleEntry

    @Environment(\.widgetFamily) var family

    var body: some View {
        ZStack {
            // Background with border
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(entry.status.borderColor, lineWidth: 6)
                )

            // Content
            VStack(spacing: 4) {
                Text(entry.status.displayText)
                    .font(.system(size: fontSize, weight: .bold, design: .rounded))
                    .foregroundColor(entry.status.borderColor)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)

                Text(entry.status.subtitleText)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.8)
                    .lineLimit(2)
            }
            .padding()
        }
    }

    /// Adjust font size based on widget family
    private var fontSize: CGFloat {
        switch family {
        case .systemSmall:
            return 40
        case .systemMedium:
            return 48
        case .systemLarge:
            return 60
        default:
            return 40
        }
    }
}

// MARK: - Widget Configuration

/// The widget definition
@main
struct InOutCycleWidget: Widget {
    let kind: String = "InOutCycleWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CycleTimelineProvider()) { entry in
            CycleWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("InOut Cycle")
        .description("Shows whether you're in the IN or OUT phase of your 28-day cycle.")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Previews

#Preview(as: .systemSmall) {
    InOutCycleWidget()
} timeline: {
    CycleEntry(date: Date(), status: .inPhase(dayInPhase: 10))
    CycleEntry(date: Date(), status: .outPhase(dayInPhase: 3))
    CycleEntry(date: Date(), status: .notConfigured)
}
