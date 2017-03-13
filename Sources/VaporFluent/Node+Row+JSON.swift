import Node
import JSON
import Fluent

enum FluentModelError: Error {
    case invalidContext(Context?)
    case unspecified(Error)
}

extension NodeInitializable where Self: JSONInitializable, Self: RowInitializable {
    public init(node: Node) throws {
        if node.context.isJSON {
            try self.init(json: node.converted())
        } else if node.context.isRow {
            try self.init(row: node.converted())
        } else {
            throw FluentModelError.invalidContext(node.context)
        }
    }
}

extension NodeRepresentable where Self: JSONRepresentable, Self: RowRepresentable {
    public func makeNode(in context: Context?) throws -> Node {
        guard let context = context else { throw FluentModelError.invalidContext(nil) }
        if context.isJSON {
            return try makeJSON().converted()
        } else if context.isRow {
            return try makeRow().converted()
        } else {
            throw FluentModelError.invalidContext(context)
        }
    }
}
