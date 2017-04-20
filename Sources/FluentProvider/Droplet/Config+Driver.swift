extension Config {
    /// Adds a configurable Driver instance.
    public func addConfigurable<
        D: Driver
    >(driver: D, name: String) {
        customAddConfigurable(instance: driver, unique: "driver", name: name)
    }
    
    /// Adds a configurable Driver class.
    public func addConfigurable<
        D: Driver & ConfigInitializable
    >(driver: D.Type, name: String) {
        customAddConfigurable(class: D.self, unique: "driver", name: name)
    }
    
    /// Resolves the configured Driver.
    public func resolveDriver() throws -> Driver {
        return try customResolve(
            unique: "driver",
            file: "fluent",
            keyPath: ["driver"],
            as: Driver.self,
            default: MemoryDriver.init
        )
    }
}
