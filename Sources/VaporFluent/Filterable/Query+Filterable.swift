import HTTP

extension QueryRepresentable where T: Filterable {
    /// filters the query using data from the request
    /// in conjunction with the `filterableKeys` property
    /// on the model's type
    public func filter(for req: Request) throws -> Query<T> {
        let query = try makeQuery()
        for key in T.filterableKeys {
            if let rawValue = req.data[key.publicKey] as? Node {
                let value = key.valueMap(rawValue)
                try query.filter(key.queryKey, key.comparison, value)
            }
        }
        return query
    }
}

extension Entity where Self: Filterable {
    /// calls `query.filter(for: request)`
    public static func filter(for req: Request) throws -> Query<Self> {
        return try query().filter(for: req)
    }
}
