import Foundation

// MARK: - AppSessionable

private protocol AppSessionable {
    
    associatedtype ValueType
    
    var key: String { get }
    var value: ValueType { get }
    var group: String? { get }
    var typeString: String { get }
    
    init(key: String, value: ValueType, group: String?)
}

// MARK: - AppItem

private struct AppItem<T> {
    private var _key: String
    private var _value: T
    private var _group: String?
}

extension AppItem : AppSessionable {
    
    private init(key: String, value: T, group: String? = nil) {
        self._key = key.lowercaseString
        self._value = value
        self._group = group
    }
    
    private var key: String {
        return self._key
    }
    
    private var group: String? {
        return self._group
    }
    
    private var value: T {
        return self._value
    }
    
    private var typeString: String {
        return "\(T.self)"
    }
}

extension AppItem : CustomStringConvertible {
    private var description : String {
        let groupName = _group ?? ""
        if groupName.isEmpty {
            return "\"\(_key)\": value: (\(_value)), type: \(typeString)"
        } else {
            return "value: (\(_value)), type: \(typeString), group: \(groupName)"
        }
    }
}

// MARK: - AppSession

/// ### AppSession
/// A simple wrapper around a dictionary type that allows one to easily share data
public class AppSession {
    
    // MARK: public Properties
    
    public static let sharedInstance = AppSession()
    
    public static var count: Int {
        return AppSession.sharedInstance._storage.count
    }
    
    public static var keys: Set<String> {
        return Set(Array(AppSession.sharedInstance._storage.keys))
    }
    
    // MARK: private Properties

    private var _storage: [String: Any] = [:]
    
    private class KeyGroupMap {
        
        private var keyGroups = [String:String]()
        
        func insertByKey(key: String, groupName: String) {
            keyGroups[key.lowercaseString] = groupName
        }
        
        func removeByKey(key: String) {
            keyGroups.removeValueForKey(key.lowercaseString)
        }
        
        func removeByGroup(groupName: String) {
            let keyGroupsWithoutGroup = keyGroups.filter { (k, v) -> Bool in
                v != groupName.lowercaseString
            }
            
            var newKeyGroups = [String:String]()
            for pair in keyGroupsWithoutGroup {
                newKeyGroups[pair.0.lowercaseString] = pair.1.lowercaseString
            }
            
            keyGroups = newKeyGroups
        }
        
        func checkForGroup(groupName: String) -> Bool {
            let keysForGroup = keyGroups.filter { (_, group) -> Bool in
                group.lowercaseString == groupName.lowercaseString
            }
            
            return !keysForGroup.isEmpty
        }
    }
    private static let keygroupMap = KeyGroupMap()
    
    // MARK: Initialization
    
    private init() {}
    
    // MARK: Methods
    
    /// set: Inserts a new key value pair into the AppSession
    /// - Parameter key: Name used to reference the session data
    /// - Parameter value: Data referenced by the key
    /// - Parameter group(Optional): Name used to lump key-value pairs together
    public static func set<T>(key: String, value: T, group: String? = nil) {
        if key.isEmpty { return }
        
        let theKey = key.lowercaseString

        if let groupKey = group where !groupKey.isEmpty {
            keygroupMap.insertByKey(theKey, groupName: groupKey.lowercaseString)
        }
        
        AppSession.sharedInstance._storage[theKey] = AppItem<T>(key: theKey, value: value)
    }
    
    /// Returns stored value from the AppSession
    /// - Parameter key: Name used to reference the session data
    public static func get<T>(key: String) -> T {
        return AppSession.getItem(key.lowercaseString).value
    }
    
    /// Performs a delete and retrieve from the Session based on the reference key
    /// - Parameter key: Name used to reference the session data
    /// - Returns: Data from the Session to be type-casted
    public static func pop<T>(key: String) -> T {
        let theKey = key.lowercaseString
        
        defer {
            AppSession.delete(theKey)
        }
        
        let value: T = AppSession.get(theKey)
        
        return value
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
    
    /// Prints debug info about the contents of the AppSession
    public static func info() {
        print("Count = \(AppSession.sharedInstance._storage.count)")
        for (_, val) in AppSession.sharedInstance._storage {
            print("[\(val)]")
        }
    }
    
    // MARK: Private Methods
    
    /// Returns a value from the AppSession based on the key
    /// - Parameter key: Name used to reference the session data
    /// - Returns: Data from the Session to be type-casted
    private static func getItem<T>(key: String) -> AppItem<T> {
        let theKey = key.lowercaseString
        
        if let appItem:AppItem<T> = AppSession.sharedInstance._storage[theKey] as? AppItem<T> {
            return appItem
        } else {
            let storedValue  = AppSession.sharedInstance._storage[theKey]
            
            if let wrappedItem = storedValue as? AppItem<Optional<T>> {
                let reCastedItem = AppItem<T>(key: theKey, value: wrappedItem.value!)
                
                return reCastedItem
            } else {
                // Handle case where storedValue is 'Any' a.k.a 'protocol<>'
                let fromStorage = storedValue as! AppItem<Any>
                let recastedItem = AppItem<T>(key: theKey, value: fromStorage.value as! T)
                
                return recastedItem
            }
        }
    }
}