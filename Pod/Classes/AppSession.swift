import Foundation

/// ### AppSession
/// A simple wrapper around a dictionary type that allows one to easily share data
public class AppSession {
    
    // MARK: Properties
    
    public static let sharedInstance = AppSession()
    
    private var _storage = [String: Any]()
    
    public static var count: Int {
        return AppSession.sharedInstance._storage.count
    }
    
    public static var keys: Set<String> {
        return Set(Array(AppSession.sharedInstance._storage.keys))
    }
    
    // MARK: Initialization
    
    private init() {}
    
    // MARK: Methods
    
    /// set: Inserts a new key value pair into the AppSession
    /// - Parameter key: Name used to reference the session data
    /// - Parameter value: Data referenced by the key
    /// - Parameter group(Optional): Name used to lump key-value pairs together
    public static func set(key: String, value: Any, group: String? = nil) {
        if key.isEmpty { return }
        
        if let groupKey = group where !groupKey.isEmpty {
            AppSession.appendGroupValue(key.lowercaseString, value: value, groupKey: groupKey.lowercaseString)
        } else {
            AppSession.sharedInstance._storage[key.lowercaseString] = value
        }
    }
    
    /// get: Returns a value from the AppSession based on the key
    /// - Parameter key: Name used to reference the session data
    /// - Returns: Data from the Session to be type-casted
    public static func get(key: String) -> Any {
        return AppSession.extract(key)
    }
    
    /// pop: Performs a delete and retrieve from the Session based on the reference key
    /// - Parameter key: Name used to reference the session data
    /// - Returns: Data from the Session to be type-casted
    public static func pop(key: String) -> Any {
        let copy = AppSession.extract(key)
        AppSession.delete(key)
        return copy
    }
    
    /// clear: Deletes all values from the session
    public static func clear() {
        AppSession.sharedInstance._storage = [:]
    }
    
    /// delete: Deletes a single value from the session based on the key
    /// - Parameter key: Name used to reference the session data
    public static func delete(key: String) {
        AppSession.sharedInstance._storage.removeValueForKey(key.lowercaseString)
    }
    
    /// contains: Given a key, returns true if the session contains a value mapped to it.
    /// - Parameter key: Name used to reference the session data
    /// - Returns: Boolean
    public static func contains(key: String) -> Bool {
        return AppSession.keys.contains(key.lowercaseString)
    }
    
    // MARK: Private Methods
    
    /// extract: Given a key, returns the Session data
    /// - Parameter key: Name used to reference the session data
    /// - Returns: Data from the Session to be type-casted
    private static func extract(key: String) -> Any {
        return unwrap(unwrap(AppSession.sharedInstance._storage[key.lowercaseString]))
    }
    
    /// appendGroup: Inserts a new key value pair into the AppSession under the provided group name
    /// - Parameter key: Name used to reference the session data
    /// - Parameter value: Data referenced by the key
    /// - Parameter groupKey: Name used to lump key-value pairs together
    private static func appendGroupValue(key: String, value: Any, groupKey: String) {
        if AppSession.keys.contains(groupKey.lowercaseString) {
            var currentGroup = (AppSession.sharedInstance._storage[groupKey.lowercaseString] as? [String:Any])
            currentGroup?[key] = value
            AppSession.sharedInstance._storage[groupKey.lowercaseString] = currentGroup
        } else {
            var newGroup = [String: Any]()
            newGroup[key.lowercaseString] = value
            AppSession.sharedInstance._storage[groupKey.lowercaseString] = newGroup
        }
    }
    
    /// [http://stackoverflow.com/questions/27989094/how-to-unwrap-an-optional-value-from-any-type](http://stackoverflow.com/questions/27989094)
    private static func unwrap(any:Any) -> Any {
        let mi = Mirror(reflecting: any)
        if mi.displayStyle != .Optional {
            return any
        }
        
        if mi.children.count == 0 { return NSNull() }
        let (_, some) = mi.children.first!
        return some
    }
}