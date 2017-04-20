import Console

public final class Provider: Vapor.Provider {
    public static let repositoryName = "fluent-provider"
    
    /// The string value for the
    /// default identifier key.
    ///
    /// The `idKey` will be used when
    /// `Model.find(_:)` or other find
    /// by identifier methods are used.
    ///
    /// This value is overriden by
    /// entities that implement the
    /// `Entity.idKey` static property.
    public let idKey: String?

    /// The default type for values stored against the identifier key.
    ///
    /// The `idType` will be accessed by those Entity implementations
    /// which do not themselves implement `Entity.idType`.
    public let idType: IdentifierType?

    /// The naming convetion to use for foreign
    /// id keys, table names, etc.
    /// ex: snake_case vs. camelCase.
    public let keyNamingConvention: KeyNamingConvention?

    /// Default request data key for page numbers
    public let defaultPageKey: String?

    /// Default page size unless otherwise specified
    public let defaultPageSize: Int?

    /// The name of Fluent's migration entity
    public let migrationEntityName: String?
    
    /// String for connecting pivot names.
    /// ex: user_pet vs. user+pet vs. user^pet
    /// default is _
    public let pivotNameConnector: String?
    
    /// If true, foreign keys will automatically
    /// be added by Fluent
    public let autoForeignKeys: Bool?

    public init(
        idKey: String? = nil,
        idType: IdentifierType? = nil,
        keyNamingConvention: KeyNamingConvention? = nil,
        defaultPageKey: String? = nil,
        defaultPageSize: Int? = nil,
        migrationEntityName: String? = nil,
        pivotNameConnector: String? = nil,
        autoForeignKeys: Bool? = nil
    ) {
        self.idKey = idKey
        self.idType = idType
        self.keyNamingConvention = keyNamingConvention
        self.defaultPageKey = defaultPageKey
        self.defaultPageSize = defaultPageSize
        self.migrationEntityName = migrationEntityName
        self.pivotNameConnector = pivotNameConnector
        self.autoForeignKeys = autoForeignKeys
    }

    public init(config: Config) throws {
        guard let fluent = config["fluent"] else {
            throw ConfigError.missingFile("fluent")
        }

        if let idType = fluent["idType"]?.string {
            switch idType {
            case "int":
                self.idType = .int
            case "uuid":
                self.idType = .uuid
            default:
                throw ConfigError.unsupported(
                    value: idType, 
                    key: ["idType"], 
                    file: "fluent"
                )
            }
        } else {
            idType = nil
        }

        if let idKey = fluent["idKey"]?.string {
            self.idKey = idKey
        } else {
            idKey = nil
        }

        if let keyNamingConvention = fluent["keyNamingConvention"]?.string {
            switch keyNamingConvention {
            case "snake_case":
                self.keyNamingConvention = .snake_case
            case "camelCase":
                self.keyNamingConvention = .camelCase
            default:
                throw ConfigError.unsupported(
                    value: keyNamingConvention, 
                    key: ["keyNamingConvention"], 
                    file: "fluent"
                )
            }
        } else {
            keyNamingConvention = nil
        }


        self.defaultPageKey = fluent["defaultPageKey"]?.string
        self.defaultPageSize = fluent["defaultPageSize"]?.int
        self.migrationEntityName = fluent["migrationEntityName"]?.string
        self.pivotNameConnector = fluent["pivotNameConnector"]?.string
        self.autoForeignKeys = fluent["autoForeignKeys"]?.bool

        // make sure they have specified a fluent.driver
        // to help avoid confusing `noDatabase` errors.
        guard fluent["driver"]?.string != nil else {
            throw ConfigError.missing(
                key: ["driver"],
                file: "fluent",
                desiredType: String.self
            )
        }
    }
    
    public func boot(_ config: Config) throws {
        config.addConfigurable(cache: FluentCache.self, name: "fluent")
        config.addConfigurable(driver: MemoryDriver.self, name: "memory")
        config.addConfigurable(driver: SQLiteDriver.self, name: "sqlite")
        config.addConfigurable(command: Prepare.self, name: "prepare")
    }
    
    public func boot(_ drop: Droplet) throws {
        // add configurable driver types, this must
        // come before the preparation calls
        let driver = try drop.config.resolveDriver()
        let database = Database(driver)
        drop.database = database
        
        if let m = self.migrationEntityName {
            Fluent.migrationEntityName = m
        }
        
        if let p = self.pivotNameConnector {
            Fluent.pivotNameConnector = p
        }
        
        if let s = self.defaultPageSize {
            Fluent.defaultPageSize = s
        }
        
        if let k = self.defaultPageKey {
            FluentProvider.defaultPageKey = k
        }
        
        if let f = self.autoForeignKeys {
            Fluent.autoForeignKeys = f
        }
        
        if let idType = self.idType {
            database.idType = idType
        }
        
        if let idKey = self.idKey {
            database.idKey = idKey
        }
        
        if let keyNamingConvention = self.keyNamingConvention {
            database.keyNamingConvention = keyNamingConvention
        }
        
        try drop.prepare()
    }

    public func beforeRun(_ drop: Droplet) throws { }
}
