import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct CycleEntry: TimelineEntry {
    let date: Date
    let status: CycleStatus
}

// MARK: - Timeline Provider

struct CycleTimelineProvider: TimelineProvider {

    func placeholder(in context: Context) -> CycleEntry {
        CycleEntry(date: Date(), status: .inPhase(dayInPhase: 0))
    }

    func getSnapshot(in context: Context, completion: @escaping (CycleEntry) -> Void) {
        let status = CycleStatusCalculator.getCurrentStatus()
        let entry = CycleEntry(date: Date(), status: status)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CycleEntry>) -> Void) {
        var entries: [CycleEntry] = []
        let calendar = Calendar.current

        for dayOffset in 0..<7 {
            guard let futureDate = calendar.date(byAdding: .day, value: dayOffset, to: Date()) else {
                continue
            }
            let startOfDay = calendar.startOfDay(for: futureDate)
            let status = CycleStatusCalculator.getStatus(for: startOfDay)
            let entry = CycleEntry(date: startOfDay, status: status)
            entries.append(entry)
        }

        if entries.isEmpty {
            entries.append(CycleEntry(date: Date(), status: .notConfigured))
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

// MARK: - Ring Shape View

struct RingShape: View {
    let isOpen: Bool
    let color: Color
    let lineWidth: CGFloat

    var body: some View {
        if isOpen {
            // Open ring (broken circle) for OUT phase
            Circle()
                .trim(from: 0.1, to: 0.9) // Gap at the top
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90)) // Rotate so gap is at top
        } else {
            // Closed ring for IN phase
            Circle()
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
        }
    }
}

// MARK: - Widget View

struct CycleWidgetEntryView: View {
    var entry: CycleEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        VStack {
            Spacer()

            // Ring shape - centered
            ZStack {
                RingShape(
                    isOpen: isRingOpen,
                    color: entry.status.gradientColor,
                    lineWidth: 14
                )
                .frame(width: 80, height: 80)
                .shadow(color: entry.status.gradientColor.opacity(0.5), radius: 12, x: 0, y: 4)

                // IN/OUT text or SET DATE inside ring
                Text(entry.status.displayText)
                    .font(.system(size: displayTextSize, weight: .bold, design: .rounded))
                    .foregroundColor(entry.status.gradientColor)
            }

            Spacer()

            // Day counter - near bottom
            Text(entry.status.subtitleText)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var displayTextSize: CGFloat {
        switch entry.status {
        case .notConfigured:
            return 14 // Smaller text for "SET DATE"
        default:
            return 24 // Normal size for "IN" or "OUT"
        }
    }

    private var isRingOpen: Bool {
        switch entry.status {
        case .outPhase:
            return true
        case .inPhase, .notConfigured:
            return false
        }
    }
}

// MARK: - Background Glow View

struct GlowBackground: View {
    let status: CycleStatus

    var body: some View {
        ZStack {
            Color(.systemBackground)

            // Radial gradient glow that matches the phase color
            RadialGradient(
                gradient: Gradient(colors: [
                    status.gradientColor.opacity(glowIntensity),
                    status.gradientColor.opacity(glowIntensity * 0.3),
                    Color.clear
                ]),
                center: .center,
                startRadius: 20,
                endRadius: 120
            )
        }
    }

    // Intensity decreases as we approach end of phase (visual "countdown")
    private var glowIntensity: Double {
        switch status {
        case .inPhase(let day):
            // Day 0: bright glow (0.35), Day 20: dim glow (0.15)
            let progress = Double(day) / 20.0
            return 0.35 - (progress * 0.20)
        case .outPhase(let day):
            // Day 0: bright glow (0.35), Day 6: dim glow (0.15)
            let progress = Double(day) / 6.0
            return 0.35 - (progress * 0.20)
        case .notConfigured:
            return 0.1
        }
    }
}

// MARK: - Widget Configuration

@main
struct RingOutWidget: Widget {
    let kind: String = "RingOutWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CycleTimelineProvider()) { entry in
            CycleWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    GlowBackground(status: entry.status)
                }
        }
        .configurationDisplayName("RingOut Cycle")
        .description("Shows IN or OUT phase of your 28-day cycle.")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    RingOutWidget()
} timeline: {
    CycleEntry(date: Date(), status: .inPhase(dayInPhase: 10))
    CycleEntry(date: Date(), status: .outPhase(dayInPhase: 3))
}
