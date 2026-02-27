import Foundation

/// Calculates the cycle status based on a start date
///
/// The cycle works as follows:
/// - Days 0-6 (7 days total): OUT phase
/// - Days 7-27 (21 days total): IN phase
/// - This creates a repeating 28-day cycle
struct CycleStatusCalculator {

    /// Shared UserDefaults for app group
    private static var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: AppConstants.appGroupId)
    }

    /// Save the cycle start date to shared storage
    /// - Parameter date: The start date of the cycle
    static func saveCycleStartDate(_ date: Date) {
        // Store as TimeInterval (seconds since reference date) for robustness
        sharedDefaults?.set(date.timeIntervalSinceReferenceDate, forKey: AppConstants.cycleStartDateKey)
    }

    /// Load the cycle start date from shared storage
    /// - Returns: The stored start date, or nil if not set or invalid
    static func loadCycleStartDate() -> Date? {
        guard let defaults = sharedDefaults else { return nil }

        // Check if the key exists
        guard defaults.object(forKey: AppConstants.cycleStartDateKey) != nil else {
            return nil
        }

        let timeInterval = defaults.double(forKey: AppConstants.cycleStartDateKey)

        // Validate that we got a reasonable value (not 0 which is default for missing Double)
        guard timeInterval != 0 else { return nil }

        return Date(timeIntervalSinceReferenceDate: timeInterval)
    }

    /// Calculate the cycle status for a given date
    /// - Parameters:
    ///   - cycleStartDate: The start date of the cycle
    ///   - currentDate: The date to check (defaults to today)
    /// - Returns: The cycle status for the given date
    static func calculateStatus(cycleStartDate: Date, for currentDate: Date = Date()) -> CycleStatus {
        let calendar = Calendar.current

        // Get start of day for both dates to ensure consistent calculation
        guard let startOfCycleDate = calendar.startOfDay(for: cycleStartDate) as Date?,
              let startOfCurrentDate = calendar.startOfDay(for: currentDate) as Date? else {
            return .notConfigured
        }

        // Calculate the number of days between the cycle start and the current date
        let components = calendar.dateComponents([.day], from: startOfCycleDate, to: startOfCurrentDate)

        guard let daysDifference = components.day else {
            return .notConfigured
        }

        // Use modular arithmetic to handle both past and future dates
        // The formula (x % 28 + 28) % 28 ensures we always get a positive result in range 0-27
        let cycleDay = ((daysDifference % 28) + 28) % 28

        // Days 0-6: OUT phase (7 days)
        // Days 7-27: IN phase (21 days)
        if cycleDay < 7 {
            return .outPhase(dayInPhase: cycleDay)
        } else {
            return .inPhase(dayInPhase: cycleDay - 7)
        }
    }

    /// Get the current status based on stored cycle start date
    /// - Returns: The current cycle status, or .notConfigured if no date is set
    static func getCurrentStatus() -> CycleStatus {
        guard let startDate = loadCycleStartDate() else {
            return .notConfigured
        }
        return calculateStatus(cycleStartDate: startDate)
    }

    /// Calculate the status for a specific date based on stored cycle start date
    /// - Parameter date: The date to check
    /// - Returns: The cycle status for that date
    static func getStatus(for date: Date) -> CycleStatus {
        guard let startDate = loadCycleStartDate() else {
            return .notConfigured
        }
        return calculateStatus(cycleStartDate: startDate, for: date)
    }
}
