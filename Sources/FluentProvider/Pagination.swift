import HTTP
import JSON

public var defaultPageKey = "page"
public var defaultPagePerKey = "size"

extension QueryRepresentable where E: Paginatable, Self: ExecutorRepresentable {
    /// Returns a paginated response using page 
    /// number from the request data
    public func paginate(
        for req: Request,
        key: String = defaultPageKey,
        perKey: String = defaultPagePerKey,
        _ sorts: [Sort] = E.defaultPageSorts
    ) throws -> Page<E> {
        let page = req.data[key]?.int ?? 1
        var per = req.data[perKey]?.int ?? E.defaultPageSize
        if let maxPer = E.maxPageSize, per > maxPer {
            per = maxPer
        }
        return try makeQuery()
            .paginate(
                page: page,
                count: per,
                sorts
            )
    }
}

extension Entity where Self: Paginatable, Self: ExecutorRepresentable {
    /// Returns a paginated response on `.all()` entities
    /// using page number from the request data
    public static func paginate(
        for req: Request,
        key: String = defaultPageKey,
        perKey: String = defaultPagePerKey,
        _ sorts: [Sort] = Self.defaultPageSorts
    ) throws -> Page<Self> {
        return try makeQuery().paginate(
            for: req,
            key: key,
            perKey: perKey,
            sorts
        )
    }
}


extension Page where E: JSONRepresentable {
    public func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("page.position.current", number)
        try json.set("page.data.total", total)
        try json.set("page.data.per", size)
        let count = Int(ceil(Double(total) / Double(size)))
        if number < count {
            try json.set("page.position.next", number + 1)
        }
        if number > 1 {
            try json.set("page.position.previous", number - 1)
        }
        try json.set("page.position.max", count)
        try json.set("data", data.makeJSON())
        return json
    }

    public func makeResponse() throws -> Response {
        return try makeJSON().makeResponse()
    }
}
