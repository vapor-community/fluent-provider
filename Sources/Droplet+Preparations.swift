
import Fluent
import Vapor

extension Droplet {
    /// The preparations that should be run by the droplet
    public var preparations: [Preparation.Type] {
        get {
            guard let existing = storage["fluentvapor-preparations"] as? [Preparation.Type] else { return [] }
            return existing
        }
        set {
            storage["fluentvapor-preparations"] = newValue
        }
    }


    /// The Database for this Droplet
    /// to run preparations on, if supplied.
    public var database: Database?{
        get {
            return storage["fluentvapor-database"] as? Database
        }
        set {
            storage["fluentvapor-database"] = newValue
        }
    }
}
