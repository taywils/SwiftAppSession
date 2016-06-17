import Foundation

public protocol AppSessionable {
    
    associatedtype ValueType
    
    var key: String { get }
    var value: ValueType { get }
    var group: String? { get }
    var typeString: String { get }
    
    init(key: String, value: ValueType, group: String?)
}

public struct AppItem<T> {
    private var _key: String
    private var _value: T
    private var _group: String?
}

extension AppItem : AppSessionable {
    
    public init(key: String, value: T, group: String? = nil) {
        self._key = key
        self._value = value
        self._group = group
    }
    
    public var key: String {
        return self._key
    }
    
    public var group: String? {
        return self._group
    }
    
    public var value: T {
        return self._value
    }
    
    public var typeString: String {
        return "\(T.self)"
    }
}

extension AppItem : CustomStringConvertible {
    public var description : String {
        let groupName = _group ?? ""
        if groupName.isEmpty {
            return "\"\(_key)\": value: (\(_value)), type: \(typeString)"
        } else {
            return "value: (\(_value)), type: \(typeString), group: \(groupName)"
        }
    }
}

/// ### AppSession
/// A simple wrapper around a dictionary type that allows one to easily share data
public class AppSession {
    
    // MARK: Properties
    
    public static let sharedInstance = AppSession()
    
    private var _storage: [String: Any] = [:]
    private var _typeStore: [String: String] = [:]
    
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
    public static func set<T>(key: String, value: T, group: String? = nil) {
        if key.isEmpty { return }

        if let groupKey = group where !groupKey.isEmpty {
            AppSession.appendGroupValue( key.lowercaseString,
                value: AppItem<T>(key: key, value: value, group: group),
                groupKey: groupKey.lowercaseString
            )
        } else {
            AppSession.sharedInstance._storage[key.lowercaseString] = AppItem<T>(key: key, value: value)
        }
    }
    
    /// Returns a value from the AppSession based on the key
    /// - Parameter key: Name used to reference the session data
    /// - Returns: Data from the Session to be type-casted
    public static func get<T>(key: String) -> AppItem<T> {
        if let appItem:AppItem<T> = AppSession.sharedInstance._storage[key] as? AppItem<T> {
            return appItem
        } else {
            let storedValue  = AppSession.sharedInstance._storage[key]!
            let wrappedItem  = storedValue as! AppItem<Optional<T>>
            let reCastedItem = AppItem<T>(key: key, value: wrappedItem.value!)
            return reCastedItem
        }
        //return AppSession.extract(key)
    }
    
    /// Performs a delete and retrieve from the Session based on the reference key
    /// - Parameter key: Name used to reference the session data
    /// - Returns: Data from the Session to be type-casted
    public static func pop(key: String) -> Any {
        let copy = AppSession.extract(key)
        AppSession.delete(key)
        return copy
    }
    
    /// Deletes all values from the session
    public static func clear() {
        AppSession.sharedInstance._storage = [:]
    }
    
    /// Deletes a single value from the session based on the key
    /// - Parameter key: Name used to reference the session data
    public static func delete(key: String) {
        AppSession.sharedInstance._storage.removeValueForKey(key.lowercaseString)
    }
    
    /// Given a key, returns true if the session contains a value mapped to it.
    /// - Parameter key: Name used to reference the session data
    /// - Returns: Boolean
    public static func contains(key: String) -> Bool {
        return AppSession.keys.contains(key.lowercaseString)
    }
    
    /// info: Prints debug info about the contents of the AppSession
    public static func info() {
        print("Count = \(AppSession.sharedInstance._storage.count)")
        for (_, val) in AppSession.sharedInstance._storage {
            print("[\(val)]")
        }
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
    private static func appendGroupValue<T>(key: String, value: T, groupKey: String) {
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