/// Filterable entities can be batch filtered
/// using input data usually from things like requests
public protocol Filterable: Entity {
    static var filterableKeys: [FilterableKey] { get }
}
