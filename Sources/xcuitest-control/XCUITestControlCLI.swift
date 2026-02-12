import ArgumentParser
import XCUITestControlModels

@main
struct XCUITestControlCLI: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "xcuitest-control",
        abstract: "Control XCUITest automation from the command line.",
        subcommands: [
            TapCommand.self,
            RightClickCommand.self,
            ScrollCommand.self,
            TypeCommand.self,
            AdjustCommand.self,
            PinchCommand.self,
            WaitCommand.self,
            ScreenshotCommand.self,
            ActivateCommand.self,
            DoneCommand.self,
            StatusCommand.self,
            ResetCommand.self,
            ReadyCommand.self,
        ]
    )
}

struct GlobalOptions: ParsableArguments {
    @Flag(name: [.short, .long], help: "Include full command in output.")
    var verbose = false

    @Option(name: [.short, .customLong("container")], help: "Container directory (sets all file paths).")
    var container: String?

    var paths: ResolvedPaths {
        PathResolver.resolve(container: container)
    }

    var commandIO: CommandIO {
        CommandIO(paths: paths)
    }
}

// MARK: - Stubbed Subcommands

struct TapCommand: ParsableCommand {
    static let configuration = CommandConfiguration(commandName: "tap", abstract: "Tap on an element.")
    @OptionGroup var globals: GlobalOptions
    func run() throws { print("Not yet implemented.") }
}

struct RightClickCommand: ParsableCommand {
    static let configuration = CommandConfiguration(commandName: "right-click", abstract: "Right-click on an element (macOS only).")
    @OptionGroup var globals: GlobalOptions
    func run() throws { print("Not yet implemented.") }
}

struct ScrollCommand: ParsableCommand {
    static let configuration = CommandConfiguration(commandName: "scroll", abstract: "Scroll in a direction.")
    @OptionGroup var globals: GlobalOptions
    func run() throws { print("Not yet implemented.") }
}

struct TypeCommand: ParsableCommand {
    static let configuration = CommandConfiguration(commandName: "type", abstract: "Type text into an element.")
    @OptionGroup var globals: GlobalOptions
    func run() throws { print("Not yet implemented.") }
}

struct AdjustCommand: ParsableCommand {
    static let configuration = CommandConfiguration(commandName: "adjust", abstract: "Adjust a slider or picker.")
    @OptionGroup var globals: GlobalOptions
    func run() throws { print("Not yet implemented.") }
}

struct PinchCommand: ParsableCommand {
    static let configuration = CommandConfiguration(commandName: "pinch", abstract: "Pinch to zoom.")
    @OptionGroup var globals: GlobalOptions
    func run() throws { print("Not yet implemented.") }
}

struct WaitCommand: ParsableCommand {
    static let configuration = CommandConfiguration(commandName: "wait", abstract: "Wait for a duration.")
    @OptionGroup var globals: GlobalOptions
    func run() throws { print("Not yet implemented.") }
}

struct ScreenshotCommand: ParsableCommand {
    static let configuration = CommandConfiguration(commandName: "screenshot", abstract: "Take a screenshot.")
    @OptionGroup var globals: GlobalOptions
    func run() throws { print("Not yet implemented.") }
}

struct ActivateCommand: ParsableCommand {
    static let configuration = CommandConfiguration(commandName: "activate", abstract: "Activate the app under test.")
    @OptionGroup var globals: GlobalOptions
    func run() throws { print("Not yet implemented.") }
}

struct DoneCommand: ParsableCommand {
    static let configuration = CommandConfiguration(commandName: "done", abstract: "Signal test completion.")
    @OptionGroup var globals: GlobalOptions
    func run() throws { print("Not yet implemented.") }
}

struct StatusCommand: ParsableCommand {
    static let configuration = CommandConfiguration(commandName: "status", abstract: "Check current command status.")
    @OptionGroup var globals: GlobalOptions
    func run() throws { print("Not yet implemented.") }
}

struct ResetCommand: ParsableCommand {
    static let configuration = CommandConfiguration(commandName: "reset", abstract: "Delete protocol files.")
    @OptionGroup var globals: GlobalOptions
    func run() throws { print("Not yet implemented.") }
}

struct ReadyCommand: ParsableCommand {
    static let configuration = CommandConfiguration(commandName: "ready", abstract: "Check if the test harness is ready.")
    @OptionGroup var globals: GlobalOptions
    func run() throws { print("Not yet implemented.") }
}
