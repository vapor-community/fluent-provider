private let fluentPreparationsKey = "fluent-vapor-preparations"

extension Config {
    /// The preparations that should be run by the droplet
    public var preparations: [Preparation.Type] {
        get {
            guard let existing = storage[fluentPreparationsKey] as? [Preparation.Type] else {
                return []
            }
            return existing
        }
        set {
            storage[fluentPreparationsKey] = newValue
        }
    }
}
