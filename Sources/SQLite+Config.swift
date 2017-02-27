extension MemoryDriver: ConfigInitializable {
    public convenience init(config: Config) throws {
        try self.init()
    }
}

extension SQLiteDriver: ConfigInitializable {
    public convenience init(config: Config) throws {
        guard let sqlite = config["sqlite"] else {
            throw ConfigError.missingFile("sqlite")
        }

        guard let path = sqlite["path"]?.string else {
            throw ConfigError.missing(
                key: ["path"], 
                file: "sqlite", 
                desiredType: String.self
            )
        }

        try self.init(path: path)
    }
}
