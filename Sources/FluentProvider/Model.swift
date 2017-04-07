import JSON
import Fluent
import TypeSafeRouting
import HTTP

public protocol Model: Entity, NodeConvertible, StringInitializable { }

extension Model {
    public init(node: Node) throws {
        try self.init(row: node.converted(in: node.context))
    }
    
    public func makeNode(in context: Context?) throws -> Node {
        return try makeRow().makeNode(in: context)
    }
}

extension ResponseRepresentable where Self: JSONRepresentable {
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
