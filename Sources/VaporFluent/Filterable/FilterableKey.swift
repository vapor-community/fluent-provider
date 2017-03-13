public struct FilterableKey {
    public typealias NodeMap = (Node) -> Node

    /// external key to pull from request data
    public let publicKey: String

    /// internal key to query the db
    public let queryKey: String

    /// the type of comparison to use when
    /// filtering this key
    public let comparison: Filter.Comparison

    /// optionally map the value through some
    /// transformation function
    public let valueMap: NodeMap

    /// creates a FilterableKey using the same
    /// public and query key
    public init(
        key: String,
        comparison: Filter.Comparison = .equals,
        valueMap: @escaping NodeMap = { $0 }
        ) {
        self.publicKey = key
        self.queryKey = key
        self.comparison = comparison
        self.valueMap = valueMap
    }

    /// creates a FilterableKey
    public init(
        publicKey: String,
        queryKey: String,
        comparison: Filter.Comparison = .equals,
        valueMap: @escaping NodeMap = { $0 }
        ) {
        self.publicKey = publicKey
        self.queryKey = queryKey
        self.comparison = comparison
        self.valueMap = valueMap
    }
}
