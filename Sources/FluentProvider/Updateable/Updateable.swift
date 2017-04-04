/// Updateable models can be batch updated 
/// by their pre-defined updateable keys.
///
/// ex: user.update(for: req)
public protocol Updateable {
    static var updateableKeys: [UpdateableKey<Self>] { get }
}

