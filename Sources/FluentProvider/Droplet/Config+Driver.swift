extension Config {
    /// Adds a configurable Driver instance.
    public func addConfigurable<
        D: Driver
    >(driver: @escaping Config.Lazy<D>, name: String) {
        customAddConfigurable(closure: driver, unique: "driver", name: name)
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
