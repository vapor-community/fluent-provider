import Vapor
import HTTP

extension Updateable {
    /// Updates an updateable entity with
    /// the data from the request
    ///
    /// Any keys not present will be ignored
    public func update(for req: Request) throws {
        for key in Self.updateableKeys {
            if let value = req.data[key.name]?.wrapped {
                let node = Node(value)
                try key.setter(self, node)
            }
        }
    }
}
