import Cache

public final class FluentCache: CacheProtocol {
    public let database: Database
    public let defaultExpiration: Date?
    public init(_ database: Database, defaultExpiration: Date? = nil) {
        self.database = database
        self.defaultExpiration = defaultExpiration
    }

    public func get(_ key: String) throws -> Node? {
        guard let entity = try _find(key) else {
            return nil
        }
        
        if let exp = entity.expiration {
            guard exp > Date() else {
                try entity.delete()
                return nil
            }
        }

        return entity.value
    }

    public func set(_ key: String, _ value: Node, expiration: Date?) throws {
        if let entity = try _find(key) {
            entity.value = value
            entity.expiration = expiration
            try entity.save()
        } else {
            let entity = CacheEntity(
                key: key,
                value: value,
                expiration: expiration
            )
            try entity.save()
        }
    }

    public func delete(_ key: String) throws {
        guard let entity = try _find(key) else {
            return
        }

        try entity.delete()
    }

    private func _find(_ key: String) throws -> CacheEntity? {
        return try Query<CacheEntity>(database).filter("key", key).first()
    }
}

extension FluentCache {
    public final class CacheEntity: Fluent.Entity {
        public static var entity = "cache"

        public var key: String
        public var value: Node
        public var expiration: Date?
        
        public let storage = Storage()

        init(key: String, value: Node, expiration: Date?) {
            self.key = key
            self.value = value
            self.expiration = expiration
        }

        public init(row: Row) throws {
            key = try row.get("key")
            value = try row.get("value")
            expiration = try row.get("expiration")
        }

        public func makeRow() throws -> Row {
            var row = Row()
            try row.set("key", key)
            try row.set("value", value)
            try row.set("expiration", expiration)
            return row
        }
    }
}

extension FluentCache.CacheEntity: Preparation {
    public static func prepare(_ database: Database) throws {
        try database.create(self) { entity in
            entity.id(for: self)
            entity.string("key")
            entity.string("value")
            entity.date("expiration", optional: true)
        }
    }

    public static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
