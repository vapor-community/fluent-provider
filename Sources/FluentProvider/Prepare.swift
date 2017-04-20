import Console
import Fluent

/// Runs the droplet's `Preparation`s.
public struct Prepare: Command {
    public let id: String = "prepare"
    
    public let signature: [Argument] = [
        Option(name: "revert", help: ["Reverts preparations"]),
        Option(name: "all", help: ["Use with `--revert` to revert entire database"])
    ]
    
    public let console: ConsoleProtocol
    public let help: [String] = [
        "runs the droplet's preparations"
    ]
    
    public init(_ console: ConsoleProtocol) {
        self.console = console
    }
    
    public func run(arguments: [String]) throws {}
}

extension Prepare: ConfigInitializable {
    public  init(config: Config) throws {
        let console = try config.resolveConsole()
        self.init(console)
    }
}
