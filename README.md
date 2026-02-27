# InOut Cycle Widget

A minimal iOS app with a home screen widget that displays "IN" or "OUT" based on a 28-day cycle.

## Requirements

- **iOS 17.0+**
- **Xcode 15.0+**
- **Swift 5.9+**

## Project Setup Instructions

### 1. Create Xcode Project

1. Open Xcode and create a new project
2. Select **iOS > App**
3. Product Name: `InOutCycleApp`
4. Interface: **SwiftUI**
5. Language: **Swift**
6. Uncheck "Include Tests" (optional)

### 2. Add Widget Extension

1. Go to **File > New > Target**
2. Select **iOS > Widget Extension**
3. Product Name: `InOutWidget`
4. **Uncheck** "Include Configuration Intent" (we use StaticConfiguration)
5. Click **Finish** and **Activate** the scheme when prompted

### 3. Configure App Group

This is **critical** for sharing data between the app and widget.

#### Create App Group (Apple Developer Portal)

1. Log in to [Apple Developer Portal](https://developer.apple.com)
2. Go to **Certificates, Identifiers & Profiles > Identifiers**
3. Click **+** to add a new identifier
4. Select **App Groups** and click **Continue**
5. Enter description (e.g., "InOut Widget Group")
6. Enter identifier: `group.com.yourcompany.InOutWidget`
7. Click **Continue** and **Register**

#### Enable App Groups in Xcode

**For the main app target (`InOutCycleApp`):**

1. Select your project in the navigator
2. Select the `InOutCycleApp` target
3. Go to **Signing & Capabilities** tab
4. Click **+ Capability**
5. Search for and add **App Groups**
6. Check the box next to your App Group identifier

**For the widget extension target (`InOutWidget`):**

1. Select the `InOutWidget` target
2. Go to **Signing & Capabilities** tab
3. Click **+ Capability**
4. Add **App Groups**
5. Check the **same** App Group identifier

### 4. Update App Group ID in Code

Open `Shared/AppConstants.swift` and update the App Group ID:

```swift
static let appGroupId = "group.com.yourcompany.InOutWidget"
```

Replace `group.com.yourcompany.InOutWidget` with your actual App Group ID.

### 5. Add Shared Files to Both Targets

The following files in the `Shared` folder must be added to **both** targets:

- `AppConstants.swift`
- `CycleStatus.swift`
- `CycleStatusCalculator.swift`

To add them:
1. Select each file in Xcode
2. In the **File Inspector** (right panel), under **Target Membership**
3. Check both `InOutCycleApp` and `InOutWidgetExtension`

### 6. Project Structure

```
InOutCycleApp/
├── InOutCycleApp.swift       # App entry point (main app target only)
├── ContentView.swift          # Main settings view (main app target only)
│
├── Shared/                    # Shared between app and widget
│   ├── AppConstants.swift     # App Group ID and keys
│   ├── CycleStatus.swift      # Status enum with colors and text
│   └── CycleStatusCalculator.swift  # Date calculation logic
│
└── InOutWidget/               # Widget extension
    └── InOutWidget.swift      # Widget provider and view
```

## Building and Running

### Run the App

1. Select the `InOutCycleApp` scheme in Xcode
2. Choose your simulator or device
3. Press **Cmd+R** to build and run
4. Select a cycle start date using the DatePicker

### Add the Widget to Home Screen

1. Go to the iOS home screen
2. Long-press on any empty space until apps jiggle
3. Tap the **+** button (top left corner)
4. Search for "InOut Cycle" or scroll to find it
5. Select the **small** widget size
6. Tap **Add Widget**
7. Position the widget and tap **Done**

### Testing

- Change the date in the app and watch the widget update
- The widget should show:
  - **"OUT"** with red border for days 0-6 of the cycle
  - **"IN"** with green border for days 7-27 of the cycle
  - **"SET DATE"** with gray border if no date is configured

## How It Works

### Cycle Logic

The 28-day cycle is calculated using modular arithmetic:

```swift
let cycleDay = ((daysDifference % 28) + 28) % 28
```

- Days 0-6 (7 days): **OUT phase**
- Days 7-27 (21 days): **IN phase**

The formula `((x % 28) + 28) % 28` ensures correct handling of both past and future dates, always producing a result in the range 0-27.

### Data Sharing

The app and widget share data through:
- **App Groups**: A shared container accessible by both targets
- **UserDefaults(suiteName:)**: Stores the cycle start date as `TimeInterval`

### Widget Updates

- The widget generates a timeline with entries for the next 7 days
- Each entry is scheduled for midnight (start of day)
- The timeline policy `.atEnd` requests a refresh after the last entry
- When you change the date in the app, `WidgetCenter.shared.reloadAllTimelines()` forces an immediate refresh

## Troubleshooting

### Widget Shows "SET DATE" After Setting a Date

- Verify App Group is enabled in **both** targets
- Ensure the App Group ID matches exactly in code and Xcode capabilities
- Check that shared files are included in both targets

### Widget Doesn't Appear in Widget Gallery

- Clean build folder (**Product > Clean Build Folder**)
- Delete the app from simulator/device and reinstall
- Restart Xcode

### Build Errors

- Ensure minimum deployment target is iOS 17.0+ for both targets
- Verify all imports are present at top of files
- Check that `@main` appears in only one file per target

## Customization

### Change Colors

Edit `CycleStatus.swift`:

```swift
var borderColor: Color {
    switch self {
    case .inPhase:
        return Color(red: 0.2, green: 0.8, blue: 0.4) // Custom green
    case .outPhase:
        return Color(red: 0.9, green: 0.2, blue: 0.2) // Custom red
    case .notConfigured:
        return .gray
    }
}
```

### Change Cycle Duration

Edit `CycleStatusCalculator.swift`:

```swift
// Example: 5 days OUT, 23 days IN (still 28-day cycle)
let cycleDay = ((daysDifference % 28) + 28) % 28
if cycleDay < 5 {  // Change from 7 to 5
    return .outPhase(dayInPhase: cycleDay)
} else {
    return .inPhase(dayInPhase: cycleDay - 5)  // Change from 7 to 5
}
```

### Add More Widget Sizes

Edit `InOutWidget.swift`:

```swift
.supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
```

## License

This is a minimal example project for educational purposes. Use and modify as needed.
