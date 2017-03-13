import HTTP

public var defaultPageKey = "page"

extension QueryRepresentable where T: Paginatable {
    /// Returns a paginated response using page 
    /// number from the request data
    public func paginate(
        for req: Request,
        key: String = defaultPageKey,
        count: Int = T.pageSize,
        _ sorts: [Sort] = T.pageSorts
    ) throws -> Page<T> {
        let page = req.data[key]?.int ?? 1
        return try makeQuery()
            .paginate(
                page: page,
                count: count,
                sorts
            )
    }
}

extension Entity where Self: Paginatable {
    /// Returns a paginated response on `.all()` entities
    /// using page number from the request data
    public static func paginate(
        for req: Request,
        key: String = defaultPageKey,
        count: Int = Self.pageSize,
        _ sorts: [Sort] = Self.pageSorts
    ) throws -> Page<Self> {
        return try query().paginate(
            for: req,
            key: key,
            count: count,
            sorts
        )
    }
}
