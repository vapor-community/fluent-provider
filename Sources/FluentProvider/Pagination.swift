import HTTP

public var defaultPageKey = "page"

extension QueryRepresentable where E: Paginatable {
    /// Returns a paginated response using page 
    /// number from the request data
    public func paginate(
        for req: Request,
        key: String = defaultPageKey,
        count: Int = E.pageSize,
        _ sorts: [Sort] = E.pageSorts
    ) throws -> Page<E> {
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


extension Page: JSONRepresentable {
    public func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("page.number", number)
        try json.set("page.total", total)
        try json.set("page.size", size)
        let count = total / size
        if number < count {
            try json.set("page.next", number + 1)
        }
        if number > 1 {
            try json.set("page.previous", number - 1)
        }
        try json.set("page.count", count)
        try json.set("data", data)
        return json
    }
}

extension Page: ResponseRepresentable {
    public func makeResponse() throws -> Response {
        return try makeJSON().makeResponse()
    }
}
