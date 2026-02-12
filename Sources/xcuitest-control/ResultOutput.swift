import Foundation
import XCUITestControlModels

enum ResultOutput {
    static func output(
        result: InteractiveCommand,
        paths: ResolvedPaths,
        verbose: Bool
    ) -> Int32 {
        let fm = FileManager.default

        var dict: [String: Any] = [
            "status": result.status.rawValue,
            "hierarchy": fm.fileExists(atPath: paths.hierarchy) ? paths.hierarchy as Any : NSNull(),
            "screenshot": fm.fileExists(atPath: paths.screenshot) ? paths.screenshot as Any : NSNull(),
        ]

        if result.status == .error {
            dict["error"] = result.errorMessage ?? "Unknown error"
        }

        if let info = result.info {
            dict["info"] = info
        }

        if verbose {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            if let data = try? encoder.encode(result),
               let obj = try? JSONSerialization.jsonObject(with: data) {
                dict["command"] = obj
            }
        }

        printJSON(dict)
        return result.status == .completed ? 0 : 1
    }

    static func printJSON(_ dict: [String: Any]) {
        if let data = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys]),
           let str = String(data: data, encoding: .utf8) {
            print(str)
        }
    }
}
