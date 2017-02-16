public final class FluentVaporProvider: Provider {
    public init() {}
    public init(config: Settings.Config) {}

    public func beforeRun(_ drop: Droplet) {
        let prepare = Prepare(console: drop.console, preparations: drop.preparations, database: drop.database)
        drop.commands.insert(prepare, at: 0)

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
