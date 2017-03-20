import JSON
import Fluent
import TypeSafeRouting
import HTTP

public protocol Model: Entity, JSONConvertible, NodeConvertible, StringInitializable, ResponseRepresentable { }

extension Model {
    public func makeResponse() throws -> Response {
        return try makeJSON().makeResponse()
    }
    
    public init(node: Node, in context: Context?) throws {
        if context?.isRow == true {
            try self.init(row: Row(node.wrapped))
        } else {
            try self.init(json: JSON(node.wrapped))
        }
    }
    
    public func makeNode(in context: Context?) throws -> Node {
        if context?.isRow  == true {
            return try Node(makeRow().wrapped)
        } else {
            return try Node(makeJSON().wrapped)
        }
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
