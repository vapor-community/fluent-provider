import JSON
import Fluent
import HTTP

public protocol Model: Entity, Parameterizable { }

// MARK: Parameterizable
extension StringInitializable where Self: Entity {
    /// the unique key to use as a slug in route building
    static var uniqueSlug: String {
        return foreignIdKey
    }
    
    // returns the found model for the resolved url parameter
    static func make(for parameter: String) throws -> Self {
        let id = Identifier(parameter)
        guard let found = try find(id) else {
            throw Abort(.notFound, reason: "No \(Self.self) with that identifier was found.")
        }
        return found
    }
}

// MARK: JSON

extension ResponseRepresentable where Self: JSONRepresentable {
    public func makeResponse() throws -> Response {
        return try makeJSON().makeResponse()
    }
}
