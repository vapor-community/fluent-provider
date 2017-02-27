import Cache

public final class FluentCache: CacheProtocol {
    public let database: Database
    public init(_ database: Database) {
        self.database = database
    }

    public func get(_ key: String) throws -> Node? {
        guard let entity = try _find(key) else {
            return nil
        }

        return entity.value
    }

    public func set(_ key: String, _ value: Node) throws {
        if let entity = try _find(key) {
            entity.value = value
            try entity.save()
        } else {
            let entity = CacheEntity(key: key, value: value)
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
        public let storage = Storage()

        init(key: String, value: Node) {
            self.key = key
            self.value = value
        }

        public init(node: Node, in context: Context) throws {
            key = try node.get("key")
            value = try node.get("value")
        }

        public func makeNode(context: Context) throws -> Node {
            return try Node(node: [
                idKey: id,
                "key": key,
                "value": value
            ])
        }

        public static func prepare(_ database: Database) throws {
            try database.create(CacheEntity.self) { entity in
                entity.id(for: self)
                entity.string("key")
                entity.string("value")
            }
        }

        public static func revert(_ database: Database) throws {
            try database.delete(CacheEntity.self)
        }
    }
}
