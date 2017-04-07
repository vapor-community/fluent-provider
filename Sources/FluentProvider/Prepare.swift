import Console
import Fluent

/// Runs the droplet's `Preparation`s.
public struct Prepare: Command {
    public let id: String = "prepare"
    
    public let signature: [Argument] = [
        Option(name: "revert", help: ["Reverts preparations"]),
        Option(name: "all", help: ["Use with `--revert` to revert entire database"])
    ]
    
    public let help: [String] = [
        "runs the droplet's preparations"
    ]
    
    public let console: ConsoleProtocol
    public let preparations: [Preparation.Type]
    public let database: Database?
    
    public init(
        console: ConsoleProtocol,
        preparations: [Preparation.Type],
        database: Database?
    ) {
        self.console = console
        self.preparations = preparations
        self.database = database
    }
    
    public func run(arguments: [String]) throws {
        guard preparations.count > 0 else {
            return
        }
        
        guard let database = database else {
            throw CommandError.general("Can not run preparations, droplet has no database")
        }
        
        if arguments.option("revert")?.bool == true {
            if arguments.option("all")?.bool == true {
                guard console.confirm("Are you sure you want to revert the entire database?", style: .warning) else {
                    console.error("Reversion cancelled")
                    return
                }
                
                try database.revertAll(preparations)
                console.print("Removing metadata")
                try database.revertMetadata()
                console.success("Reversion complete")
            } else {
                let (batch, toBeReverted) = try database.previewRevertBatch(preparations)
                let list = toBeReverted.map { "\($0)" }.joined(separator: ", ")
                
                guard toBeReverted.count > 0 else {
                    console.print("Nothing to be reverted")
                    return
                }
                
                guard console.confirm("Are you sure you want to revert batch \(batch) (\(list))?", style: .warning) else {
                    console.error("Reversion cancelled")
                    return
                }
                
                try database.revertBatch(preparations)
            }
        } else {
            try database.prepare(preparations)
            console.info("Database prepared")
        }
    }
}
