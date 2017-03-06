import JSON
import Fluent
import TypeSafeRouting
import HTTP

public protocol Model: Entity, JSONRepresentable, StringInitializable, ResponseRepresentable { }

extension Model {
    public func makeResponse() throws -> Response {
        return try makeJSON().makeResponse()
    }
}

// MARK: StringInitializable
extension StringInitializable where Self: Entity {
    public init?(from string: String) throws {
        if let model = try Self.find(string) {
            self = model
        } else {
            return nil
        }
    }
}
