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

// MARK: JSONRepresentable
extension Model {
    public func makeJSON() throws -> JSON {
        let node = try makeNode()
        return try JSON(node: node)
    }
}

// MARK: StringInitializable
extension Entity {
    public init?(from string: String) throws {
        // FIXME: hacky
        let node = try Self.query().filter(Self.idKey, .equals, string).raw()
        if case .array(let array) = node, let first = array.first {
            try self.init(node: first)
            id = first[Self.idKey]
        } else {
            return nil
        }
    }
}
