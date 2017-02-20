public final class Provider: Vapor.Provider {
    public init() {}
    public init(config: Settings.Config) {}

    public func beforeRun(_ drop: Droplet) {
        let prepare = Prepare(console: drop.console, preparations: drop.preparations, database: drop.database)
        drop.commands.insert(prepare, at: 0)
        // ensure we're not already preparing so we avoid running twice
        guard !drop.arguments.contains(prepare.id) else { return }
        
        // TODO: Propagate error up when Providers have `beforeRun` throwing
        /// Preparations run everytime to ensure database is configured properly
        do {
            try prepare.run(arguments: drop.arguments)
        } catch {
            drop.log.error("Preparations Failed \(error)")
        }
    }

    public func boot(_ drop: Droplet) {}
}
