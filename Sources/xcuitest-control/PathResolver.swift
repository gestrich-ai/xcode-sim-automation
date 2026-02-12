import Foundation

struct ResolvedPaths: Sendable {
    let command: String
    let hierarchy: String
    let screenshot: String
}

enum PathResolver {
    static func resolve(container: String?) -> ResolvedPaths {
        if let container {
            let base = NSString(string: container).expandingTildeInPath
            return ResolvedPaths(
                command: (base as NSString).appendingPathComponent("xcuitest-command.json"),
                hierarchy: (base as NSString).appendingPathComponent("xcuitest-hierarchy.txt"),
                screenshot: (base as NSString).appendingPathComponent("xcuitest-screenshot.png")
            )
        }

        return ResolvedPaths(
            command: ProcessInfo.processInfo.environment["XCUITEST_COMMAND_PATH"]
                ?? "/tmp/xcuitest-command.json",
            hierarchy: ProcessInfo.processInfo.environment["XCUITEST_HIERARCHY_PATH"]
                ?? "/tmp/xcuitest-hierarchy.txt",
            screenshot: ProcessInfo.processInfo.environment["XCUITEST_SCREENSHOT_PATH"]
                ?? "/tmp/xcuitest-screenshot.png"
        )
    }
}
