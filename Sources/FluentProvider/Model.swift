import JSON
import Fluent
import HTTP

public protocol Model: Entity, StringInitializable { }

extension ResponseRepresentable where Self: JSONRepresentable {
    public func makeResponse() throws -> Response {
        return try makeJSON().makeResponse()
    }
}

// MARK: StringInitializable
extension StringInitializable where Self: Entity {
    public init?(_ string: String) throws {
        if let model = try Self.find(string) {
            self = model
        } else {
            return nil
        }
    }
}
