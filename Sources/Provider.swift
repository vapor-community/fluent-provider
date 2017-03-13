public final class Provider: Vapor.Provider {
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

    /// String for connecting pivot names.
    /// ex: user_pet vs. user+pet vs. user^pet
    /// default is _
    public let pivotNameConnector: String?

    public init(
        idKey: String? = nil,
        idType: IdentifierType? = nil,
        keyNamingConvention: KeyNamingConvention? = nil,
        defaultPageKey: String? = nil,
        defaultPageSize: Int? = nil,
        pivotNameConnector: String? = nil
    ) {
        self.idKey = idKey
        self.idType = idType
        self.keyNamingConvention = keyNamingConvention
        self.defaultPageKey = defaultPageKey
        self.defaultPageSize = defaultPageSize
        self.pivotNameConnector = pivotNameConnector
    }

    public init(config: Settings.Config) throws {
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
        self.pivotNameConnector = fluent["pivotNameConnector"]?.string

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

    public func beforeRun(_ drop: Droplet) throws {
        // add configurable driver types, this must 
        // come before the preparation calls
        try drop.addConfigurable(driver: MemoryDriver.self, name: "memory")
        try drop.addConfigurable(driver: SQLiteDriver.self, name: "sqlite")

        if let p = self.pivotNameConnector {
            Fluent.pivotNameConnector = p
        }

        if let k = self.defaultPageKey {
            VaporFluent.defaultPageKey = k
        }

        if let db = drop.database {
            drop.addConfigurable(cache: FluentCache(db), name: "fluent")    

            if let idType = self.idType {
                db.idType = idType
            }

            if let idKey = self.idKey {
                db.idKey = idKey
            }

            if let keyNamingConvention = self.keyNamingConvention {
                db.keyNamingConvention = keyNamingConvention
            }
        } else {
            let driver = drop.config["fluent", "driver"]?.string ?? ""
            let reason = "Make sure you have properly configured the provider for driver type '\(driver)'"
            if drop.preparations.count > 0 {
                drop.log.error("Unable to run preparations without a database. \(reason).")
                throw ConfigError.unsupported(
                    value: driver, 
                    key: ["driver"], 
                    file: "fluent"
                )
            } else {
                drop.log.warning("No database has been set. \(reason).")
            }
        }

        if drop.preparations.count == 0 {
            drop.log.warning("No preparations detected.")
            drop.log.info("If you want to use models with Fluent, make sure to add the model to the Droplet's preparations array, e.g., `drop.preparations += ModelType.self`.")
        }

        let prepare = Prepare(
            console: drop.console, 
            preparations: drop.preparations, 
            database: drop.database
        )
        drop.commands.insert(prepare, at: 0)

        // ensure we're not already preparing so we avoid running twice
        guard drop.arguments.count < 2 || drop.arguments[1] != prepare.id else {
            return
        }
        
        // TODO: Propagate error up when Providers have `beforeRun` throwing
        /// Preparations run everytime to ensure database is configured properly
        try prepare.run(arguments: drop.arguments)
    }

    public func boot(_ drop: Droplet) {}
}
