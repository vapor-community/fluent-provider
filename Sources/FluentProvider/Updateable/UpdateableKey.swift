/// Represents an updateable key and
/// the setter for when a new value is 
/// given for the key.
public class UpdateableKey<M> {
    public var name: String
    public var setter: (M, Node) throws -> ()
    
    init<N: NodeInitializable>(
        _ name: String,
        _ type: N.Type = N.self,
        _ setter: @escaping (M, N) throws -> ()
    ) {
        self.name = name
        self.setter = { m, node in
            let n = try N(node: node)
            try setter(m, n)
        }
    }
}
