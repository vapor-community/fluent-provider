import Vapor
import Fluent

extension Droplet {
    /// Adds Driver to the Droplet the `fluent.json` specifies it.
    public func addConfigurable(driver: Driver, name: String) {
        let configuredDriver = config["fluent", "driver"]?.string ?? name
        if configuredDriver == name {
            set(driver)
            self.log.debug("Using database driver '\(name)'.")
        } else {
            self.log.debug("Not using database driver '\(name)'.")
        }
    }

    /// Adds a ConfigInitializable Driver type to the Droplet if
    /// the `fluent.json` specifies it.
    public func addConfigurable<D: Driver & ConfigInitializable>(driver: D.Type, name: String) {
        let configuredDriver = config["fluent", "driver"]?.string ?? name

        do {
            if configuredDriver == name {
                let driver = try driver.init(config: config)
                set(driver)
                self.log.debug("Using database driver '\(name)'.")
            } else {
                self.log.debug("Not using database driver '\(name)'. Configured for '\(name)'")
            }
        } catch {
            self.log.warning("Could not configure database driver '\(name)': \(error)")
        }
    }

    /// Sets the driver to this Droplet by
    /// creating a Database.
    private func set(_ driver: Driver) {
        if let existing = self.database?.driver {
            log.warning("overwriting existing driver \(existing) with \(driver)")
        }

        if let maxConnections = config["fluent", "maxConnections"]?.int {
            self.database = Database(driver, maxConnections: maxConnections)
        } else {
            self.database = Database(driver)
        }
    }
}
