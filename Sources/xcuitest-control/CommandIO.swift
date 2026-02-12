import Foundation
import XCUITestControlModels

struct CommandIO {
    let paths: ResolvedPaths

    private static let pollInterval: TimeInterval = 0.2
    private static let pollTimeout: TimeInterval = 30.0

    func writeCommand(_ command: InteractiveCommand) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(command)
        try data.write(to: URL(fileURLWithPath: paths.command))
    }

    func readCommand() -> InteractiveCommand? {
        guard FileManager.default.fileExists(atPath: paths.command) else { return nil }
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: paths.command)) else { return nil }
        return try? JSONDecoder().decode(InteractiveCommand.self, from: data)
    }

    func waitForCompletion(timeout: TimeInterval = pollTimeout) -> InteractiveCommand {
        let start = Date()

        while Date().timeIntervalSince(start) < timeout {
            if let command = readCommand() {
                switch command.status {
                case .completed, .error:
                    return command
                case .pending, .executing:
                    break
                }
            }
            Thread.sleep(forTimeInterval: Self.pollInterval)
        }

        return InteractiveCommand(
            action: .done,
            status: .error,
            errorMessage: "Timeout after \(Int(timeout)) seconds"
        )
    }
}
