import Fluent
import Vapor

private let fluentDatabaseKey = "fluent-vapor-database"

extension Droplet {
    internal var database: Database?{
        get {
            return storage[fluentDatabaseKey] as? Database
        }
        set {
            storage[fluentDatabaseKey] = newValue
        }
    }


    func assertDatabase() throws -> Database {
        guard let database = self.database else {
            throw FluentProviderError.noDatabase
        }
        return database
    }
}


public enum FluentProviderError: Error {
    case noDatabase
}
