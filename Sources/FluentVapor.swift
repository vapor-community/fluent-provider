import Cache

public final class FluentCache: CacheProtocol {
    public let database: Database
    public init(database: Database) {
        self.database = database
    }

    public func get(_ key: String) throws -> Node? {
        guard let entity = try _find(key) else {
            return nil
        }

        return entity.value
    }

    public func set(_ key: String, _ value: Node) throws {
        if var entity = try _find(key) {
            try entity.save()
        } else {
            var entity = CacheEntity(key: key, value: value)
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

        public var id: Node?
        public var key: String
        public var value: Node

        public var exists = false

        init(key: String, value: Node) {
            self.key = key
            self.value = value
        }

        public init(node: Node, in context: Context) throws {
            id = try node.extract("id")
            key = try node.extract("key")
            value = try node.extract("value")
        }

        public func makeNode(context: Context) throws -> Node {
            return try Node(node: [
                "id": id,
                "key": key,
                "value": value
            ])
        }

        public static func prepare(_ database: Database) throws {
            try database.create(CacheEntity.entity) { entity in
                entity.id(for: self)
                entity.string("key")
                entity.string("value")
            }
        }

        public  static func revert(_ database: Database) throws {
            try database.delete(CacheEntity.entity)
        }
    }
}
