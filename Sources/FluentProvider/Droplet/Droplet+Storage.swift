import Fluent
import Vapor

private let fluentDatabaseKey = "fluent-vapor-database"

extension Droplet {
    public internal(set) var database: Database? {
        get {
            return storage[fluentDatabaseKey] as? Database
        }
        set {
            storage[fluentDatabaseKey] = newValue
        }
    }
    
    
    public func assertDatabase() throws -> Database {
        guard let database = self.database else {
            throw FluentProviderError.noDatabase
        }
        return database
    }
}


public enum FluentProviderError: Error {
    case noDatabase
}

extension FluentProviderError: Debuggable {
    public var reason: String {
        switch self {
        case .noDatabase:
            return "No database has been configured."
        }
    }
    
    public var identifier: String {
        switch self {
        case .noDatabase:
            return "noDatabase"
        }
    }
    
    public var possibleCauses: [String] {
        switch self {
        case .noDatabase:
            return [
                "You have not added the `MySQLProvider.Provider` to your Droplet."
            ]
        }
    }
    
    public var suggestedFixes: [String] {
        return []
    }
}
