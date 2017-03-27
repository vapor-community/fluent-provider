extension FilterableKey: ExpressibleByUnicodeScalarLiteral {
    public init(unicodeScalarLiteral value: String) {
        self.init(key: value)
    }
}

extension FilterableKey: ExpressibleByExtendedGraphemeClusterLiteral {
    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(key: value)
    }
}

extension FilterableKey: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(key: value)
    }
}
