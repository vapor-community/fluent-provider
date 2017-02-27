import Console
import Fluent

/// Runs the droplet's `Preparation`s.
public struct Prepare: Command {
    public let id: String = "prepare"

    public let signature: [Argument] = [
        Option(name: "revert"),
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
            console.info("No preparations.")
            return
        }

        guard let database = database else {
            throw CommandError.general("Can not run preparations, droplet has no database")
        }

        if arguments.option("revert")?.bool == true {
            try revert(database)
        } else {
            try prepare(database)
        }
    }

    private func prepare(_ database: Database) throws {
        try preparations.forEach { preparation in
            let name = "\(preparation.self)"

            let hasPrepared = try database.hasPrepared(preparation)
            // only prepare the unprepared
            guard !hasPrepared else { 
                if let model = preparation as? Entity.Type {
                    // db prepared, allow model to access 
                    model.database = database
                }
                return 
            }

            console.info("Preparing \(name)")
            try database.prepare(preparation)
            console.success("Prepared \(name)")
        }

        console.info("Database prepared")
    }

    private func revert(_ database: Database) throws {
        guard console.confirm("Are you sure you want to revert the database?", style: .warning) else {
            console.error("Reversion cancelled")
            return
        }


        try preparations.reversed().forEach { preparation in
            let name = "\(preparation.self)"

            let hasPrepared = try database.hasPrepared(preparation)
            // if not prepared yet, no need to revert
            guard hasPrepared else { return }

            try preparation.revert(database)
            console.success("Reverted \(name)")
        }

        console.print("Removing metadata")
        let schema = Schema.delete(entity: "fluent")
        try database.driver.schema(schema)
        console.success("Reversion complete")
    }
}
