import SwiftUI
import WidgetKit

/// Main settings view for configuring the cycle start date
struct ContentView: View {
    /// The selected cycle start date
    @State private var cycleStartDate: Date = Date()

    /// Whether a date has been configured
    @State private var hasConfiguredDate: Bool = false

    /// Current status for preview
    @State private var currentStatus: CycleStatus = .notConfigured

    var body: some View {
        NavigationView {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Configure your cycle start date below. The widget will show:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        HStack(spacing: 20) {
                            VStack {
                                Text("OUT")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                Text("7 days")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Image(systemName: "arrow.right")
                                .foregroundColor(.secondary)

                            VStack {
                                Text("IN")
                                    .font(.headline)
                                    .foregroundColor(.green)
                                Text("21 days")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Image(systemName: "arrow.right")
                                .foregroundColor(.secondary)

                            Text("Repeat")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                } header: {
                    Text("About")
                }

                Section {
                    DatePicker(
                        "Cycle start date",
                        selection: $cycleStartDate,
                        displayedComponents: .date
                    )
                    .onChange(of: cycleStartDate) { _, newValue in
                        saveDateAndRefreshWidget(newValue)
                    }
                } header: {
                    Text("Configuration")
                } footer: {
                    Text("Select the first day of your OUT phase. The 7-day OUT period starts on this date.")
                }

                if hasConfiguredDate {
                    Section {
                        HStack {
                            Spacer()
                            VStack(spacing: 8) {
                                Text(currentStatus.displayText)
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundColor(currentStatus.borderColor)

                                Text(currentStatus.subtitleText)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 12)
                    } header: {
                        Text("Current Status")
                    }
                }

                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("How to add the widget:")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        Text("1. Long-press on your home screen")
                        Text("2. Tap the '+' button in the top left")
                        Text("3. Search for 'InOut Cycle'")
                        Text("4. Select the small widget size")
                        Text("5. Tap 'Add Widget'")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                } header: {
                    Text("Widget Instructions")
                }
            }
            .navigationTitle("Cycle Widget Settings")
        }
        .onAppear {
            loadSavedDate()
        }
    }

    /// Load any previously saved date
    private func loadSavedDate() {
        if let savedDate = CycleStatusCalculator.loadCycleStartDate() {
            cycleStartDate = savedDate
            hasConfiguredDate = true
            currentStatus = CycleStatusCalculator.getCurrentStatus()
        }
    }

    /// Save the date and refresh the widget
    private func saveDateAndRefreshWidget(_ date: Date) {
        CycleStatusCalculator.saveCycleStartDate(date)
        hasConfiguredDate = true
        currentStatus = CycleStatusCalculator.calculateStatus(cycleStartDate: date)

        // Tell WidgetKit to refresh the widget timeline
        WidgetCenter.shared.reloadAllTimelines()
    }
}

#Preview {
    ContentView()
}
