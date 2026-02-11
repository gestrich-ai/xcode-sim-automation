# Element Type Discovery

## CRITICAL: Element Types Don't Match Visual Appearance

XCUITest queries are **type-specific**. This means:
- `app.buttons["FBOs"]` will **NOT** find a StaticText labeled "FBOs"
- `app.staticTexts["Settings"]` will **NOT** find a Button labeled "Settings"

Even though both elements might look identical and be tappable, you **must** use the correct element type in your query.

## Common Misconceptions

| Visual Appearance | Common Assumption | Actual Type (Often) |
|-------------------|-------------------|---------------------|
| Tappable link text | Button | **StaticText** |
| Quick action in a list | Button | **StaticText** inside Other |
| Menu item in table | Button | **Cell** or **StaticText** |
| Segmented control item | Button | **Button** (correct) |
| Tab bar item | Button | **Button** (usually correct) |
| Icon that opens something | Button | **Image** or **Button** |

## Try Multiple Element Types

Instead of guessing, try both common types. Use a short timeout for the first attempt:

```swift
// Try as Button first (short timeout), then StaticText
var element = app.buttons["MyElement"]
if !element.waitForExistence(timeout: 2.0) {
    element = app.staticTexts["MyElement"]
}
XCTAssertTrue(element.waitForExistence(timeout: 5.0), "MyElement should exist (as Button or StaticText)")
element.tap()
```

Or use the `findTappable` helper from the test template.

## Reading the UI Hierarchy

The hierarchy shows element types explicitly:

```
Other, identifier: 'QuickActions'
  ↳ StaticText, label: 'Action1'        ← This is a StaticText, NOT a Button!
  ↳ StaticText, label: 'Action2'
Button, identifier: 'MainButton', label: 'MainButton'  ← This IS a Button
```

From this you can determine:
- "Action1" is a **StaticText** → use `app.staticTexts["Action1"]`
- "MainButton" is a **Button** → use `app.buttons["MainButton"]`

## Hierarchy Examples

### Toolbar with nested elements
```
Button, identifier: "Manage configurations", label: "Manage configurations"
  ↳ Image, label: "gear"
```
→ Use `app.buttons["Manage configurations"]`

### Table with cells
```
Table
   ↳ Cell, identifier: "SettingsCell"
      ↳ StaticText, label: "Settings"
```
→ Use `app.cells["SettingsCell"]` or `app.cells.staticTexts["Settings"]`

### Tab bar
```
TabBar
   ↳ Button, identifier: "Home", label: "Home"
   ↳ Button, identifier: "Settings", label: "Settings"
```
→ Use `app.buttons["Home"]`

## Iterative Debugging Workflow

When navigation code needs fixing:

1. **Run test** → Test fails at some step
2. **Check hierarchy files** → Open the step hierarchy files from the xcresult attachments
3. **Find the issue** → The hierarchy from the step BEFORE failure shows what was actually on screen
4. **Update test** → Fix the navigation code (wrong element type? wrong identifier?)
5. **Re-run test** → Just re-run `xcodebuild test`

The `captureHierarchy` calls in the test template create hierarchy snapshots at each navigation step, so you always have context about what was on screen when something went wrong.

## UI Hierarchy Debugging

### Automatic Capture

The test template includes `captureHierarchy` calls that save `app.debugDescription` as attachments. This provides:
- Complete element tree with accessibility identifiers
- Element types (Button, StaticText, Cell, etc.)
- Element values and labels
- Element hierarchy and nesting

### Debug at Specific Points

Use the `captureHierarchy` helper at each navigation step:

```swift
captureHierarchy(name: "Step1-AfterLogin")
// ... navigate ...
captureHierarchy(name: "Step2-AfterTabSwitch")
// ... navigate ...
captureHierarchy(name: "Step3-AfterSearch")
```

This creates multiple hierarchy files in the output, letting you see exactly what was on screen at each point.
