public final class Provider: Vapor.Provider {
    public init() {}
    public init(config: Settings.Config) {}

    public func beforeRun(_ drop: Droplet) throws {
        // add configurable driver types, this must 
        // come before the preparation calls
        try drop.addConfigurable(driver: MemoryDriver.self, name: "memory")
        try drop.addConfigurable(driver: SQLiteDriver.self, name: "sqlite")

        if let db = drop.database {
            drop.addConfigurable(cache: FluentCache(db), name: "fluent")    
        }

        let prepare = Prepare(
            console: drop.console, 
            preparations: drop.preparations, 
            database: drop.database
        )
        drop.commands.insert(prepare, at: 0)

        // ensure we're not already preparing so we avoid running twice
        guard drop.arguments.count < 2 || drop.arguments[1] != prepare.id else {
            return
        }
        
        // TODO: Propagate error up when Providers have `beforeRun` throwing
        /// Preparations run everytime to ensure database is configured properly
        try prepare.run(arguments: drop.arguments)
    }

    public func boot(_ drop: Droplet) {}
}
