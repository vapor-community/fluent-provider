
import Fluent
import Vapor

private let fluentPreparationsKey = "fluentvapor-preparations"
private let fluentDatabaseKey = "fluentvapor-database"

extension Droplet {
    /// The preparations that should be run by the droplet
    public var preparations: [Preparation.Type] {
        get {
            guard let existing = storage[fluentPreparationsKey] as? [Preparation.Type] else { return [] }
            return existing
        }
        set {
            storage[fluentPreparationsKey] = newValue
        }
    }


    /// The Database for this Droplet
    /// to run preparations on, if supplied.
    public var database: Database?{
        get {
            return storage[fluentDatabaseKey] as? Database
        }
        set {
            storage[fluentDatabaseKey] = newValue
        }
    }
}
