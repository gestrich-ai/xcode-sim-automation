# Test Creation Patterns

## Helper Functions

### captureHierarchy

Saves the UI state at each navigation step for debugging. If a later step fails, you can examine the hierarchy from earlier steps to see what was actually on screen.

```swift
func captureHierarchy(name: String) {
    let hierarchy = XCTAttachment(string: app.debugDescription)
    hierarchy.name = "\(name).txt"
    hierarchy.lifetime = .keepAlways
    add(hierarchy)
}
```

### findTappable

Tries multiple element types automatically, since XCUITest queries are type-specific. A visual "button" might actually be a StaticText or Cell.

```swift
func findTappable(_ identifier: String) -> XCUIElement {
    let button = app.buttons[identifier]
    if button.waitForExistence(timeout: 2.0) { return button }

    let staticText = app.staticTexts[identifier]
    if staticText.waitForExistence(timeout: 2.0) { return staticText }

    let cell = app.cells[identifier]
    if cell.waitForExistence(timeout: 2.0) { return cell }

    return button // Fallback - assertion will fail with clear message
}
```

## Navigation Patterns

### CRITICAL: Use Assertions for Every Navigation Step

**Every navigation step MUST use `XCTAssertTrue` to verify the element exists before interacting with it.** This ensures the test fails immediately if navigation goes wrong, rather than silently continuing and taking a screenshot of the wrong view.

### Tab Bar Views

```swift
let tabButton = app.buttons["TabName"]
XCTAssertTrue(tabButton.waitForExistence(timeout: 10.0), "TabName tab should exist")
tabButton.tap()
```

### Table/List Items

```swift
let menuItem = app.cells.staticTexts["MenuItem"]
XCTAssertTrue(menuItem.waitForExistence(timeout: 5.0), "MenuItem should exist")
menuItem.tap()
```

### SwiftUI Sheets/Modals

```swift
let showButton = app.buttons["AccessibilityID"]
XCTAssertTrue(showButton.waitForExistence(timeout: 10.0), "Show button should exist")
showButton.tap()
sleep(2) // Wait for animation
```

### Multi-Step Navigation

For views that require multiple navigation steps, capture hierarchy at each step and use `findTappable` for uncertain elements:

```swift
// Step 1: Go to a tab
let tab = app.buttons["MyTab"]
XCTAssertTrue(tab.waitForExistence(timeout: 10.0), "MyTab tab should exist")
tab.tap()
sleep(2)
captureHierarchy(name: "Step1-AfterTab")

// Step 2: Navigate deeper - could be Button or StaticText
let target = findTappable("TargetItem")
XCTAssertTrue(target.exists, "TargetItem should exist")
target.tap()
sleep(2)
captureHierarchy(name: "Step2-AfterTarget")

// Take the screenshot
let screenshot = app.screenshot()
let attachment = XCTAttachment(screenshot: screenshot)
attachment.name = "TargetView"
attachment.lifetime = .keepAlways
add(attachment)
```

With hierarchy captures at each step, if the test fails at Step 2, you can examine `Step1-AfterTab.txt` to see what was actually on screen.

## Build-First Pattern

Always build before running tests to catch compilation errors early:

```bash
# Step 1: Build (catches errors without hanging)
xcodebuild build-for-testing \
  -project $PROJECT \
  -scheme $SCHEME \
  -destination '$DESTINATION'

# Step 2: Run the specific test
xcodebuild test \
  -project $PROJECT \
  -scheme $SCHEME \
  -destination '$DESTINATION' \
  -only-testing:"$UI_TEST_TARGET/ScreenshotTest_MyFeature/testMyFeatureScreenshot"
```

`xcodebuild test` can hang if the build fails, so always separate the build step.

## Assertion Requirements

- **ALWAYS** use `XCTAssertTrue(element.waitForExistence(timeout:), "message")` before tapping
- **NEVER** use `if element.exists` for navigation — it silently skips steps
- Use clear assertion messages that identify the step: `"Config 'test-repo' should exist in sidebar"`
- Each step should have its own assertion so failures pinpoint the exact navigation step
