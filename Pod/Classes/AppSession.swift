import Foundation

public typealias AppSessionGroup  = [String: Any]

/// ### AppSession
/// A simple wrapper around a dictionary type that allows one to easily share data
public class AppSession {
    
    // MARK: Properties
    
    public static let sharedInstance = AppSession()
    
    private var _storage = AppSessionGroup()
    private var _groupNames = Set<String>()
    
    private struct AppSessionInfoObj: CustomStringConvertible {
        var key:String
        var valueType:String
        var group:String
        
        var keyGroup: String {
            return "\(key)_\(group)"
        }
        
        init(key:String, valueType:String, group:String = "") {
            self.key = key
            self.valueType = valueType
            self.group = group
        }
        
        var description: String {
            return "|Key: \"\(key)\", Type: \(valueType), Group: \"\(group)\""
        }
    }
    private var _infos = [AppSessionInfoObj]()
    
    public static var count: Int {
        return AppSession.sharedInstance._storage.count
    }
    
    public static var keys: Set<String> {
        return Set(Array(AppSession.sharedInstance._storage.keys))
    }
    
    public static var groups: Set<String> {
        return AppSession.sharedInstance._groupNames
    }
    
    // MARK: Initialization
    
    private init() {}
    
    // MARK: Methods
    
    /// Inserts a new key value pair into the AppSession
    /// - Parameter key: Name used to reference the session data
    /// - Parameter value: Data referenced by the key
    /// - Parameter group(Optional): Name used to lump key-value pairs together
    public static func set<T>(key: String, value: T, group: String = "") {
        if key.isEmpty { return }
        
        let theKey = key.lowercaseString
        let theGroup = group.lowercaseString

        
        if !group.isEmpty {
            let groupDoesntExist = !AppSession.sharedInstance._groupNames.contains(theGroup)
            let keyExistsWithGroupName = AppSession.contains(theGroup)
            
            if groupDoesntExist && keyExistsWithGroupName {
                AppSession.delete(theGroup)
            } else if keyExistsWithGroupName {
                // Overwriting the group
                AppSession.removeInfoObjByKeyInGroup(theKey, groupName: theGroup)
            }
            
            AppSession.sharedInstance._groupNames.insert(theGroup)
            AppSession.appendGroupValue(theKey, value: value, groupKey: theGroup)
        } else {
            let groupNameWithKeyExists = AppSession.sharedInstance._groupNames.contains(theKey)
            let theKeyIsCurrentlyInUse = AppSession.contains(theKey)
            
            if groupNameWithKeyExists || theKeyIsCurrentlyInUse {
                AppSession.delete(theKey)
            }

            AppSession.sharedInstance._storage[theKey] = value
        }
        
        AppSession.sharedInstance._infos.append(AppSessionInfoObj(key: theKey, valueType: String(T.self), group: theGroup))
    }
    
    /// Returns a value from the AppSession based on the key
    /// - Parameter key: Name used to reference the session data
    /// - Returns: Data from the Session to be type-casted
    public static func get(key: String) -> Any {
        return AppSession.extract(key)
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
        AppSession.sharedInstance._infos = [AppSessionInfoObj]()
        AppSession.sharedInstance._storage = [:]
        AppSession.sharedInstance._groupNames = Set<String>()
    }
    
    /// Deletes a single value from the session based on the key
    /// - Parameter key: Name used to reference the session data
    public static func delete(key: String) {
        let theKey = key.lowercaseString
        
        if AppSession.sharedInstance._groupNames.contains(theKey) {
            AppSession.removeInfoObj(theKey, clearGroup: true)
            AppSession.sharedInstance._groupNames.remove(theKey)
        } else {
            AppSession.removeInfoObj(theKey)
        }
        
        AppSession.sharedInstance._storage.removeValueForKey(theKey)
    }
    
    /// Given a key, returns true if the session contains a value mapped to it.
    /// - Parameter key: Name used to reference the session data
    /// - Returns: Boolean
    public static func contains(key: String) -> Bool {
        return AppSession.keys.contains(key.lowercaseString)
    }
    
    /// Returns a DEBUG dump of the current values stored in AppSession
    public static func info() {
        print("📖 AppSession #DEBUG")
        for infoObj in AppSession.sharedInstance._infos {
            print(infoObj)
        }
    }
    
    // MARK: Private Methods
    
    /// Given a key, returns the Session data
    /// - Parameter key: Name used to reference the session data
    /// - Returns: Data from the Session to be type-casted
    private static func extract(key: String) -> Any {
        return unwrap(unwrap(AppSession.sharedInstance._storage[key.lowercaseString]))
    }
    
    /// Inserts a new key value pair into the AppSession under the provided group name
    /// - Parameter key: Name used to reference the session data
    /// - Parameter value: Data referenced by the key
    /// - Parameter groupKey: Name used to lump key-value pairs together
    private static func appendGroupValue(key: String, value: Any, groupKey: String) {
        if AppSession.keys.contains(groupKey.lowercaseString) {
            var currentGroup = (AppSession.sharedInstance._storage[groupKey.lowercaseString] as? AppSessionGroup)
            currentGroup?[key] = value
            AppSession.sharedInstance._storage[groupKey.lowercaseString] = currentGroup
        } else {
            var newGroup = AppSessionGroup()
            newGroup[key.lowercaseString] = value
            AppSession.sharedInstance._storage[groupKey.lowercaseString] = newGroup
        }
    }
    
    /// Removes a given AppSessionInfoObj from the _infos array via key lookup
    /// - Parameter key: Name used to reference the AppSessionInfoObj
    /// - Parameter clearGroup: True will remove all AppSessionInfoObj with group
    private static func removeInfoObj(key: String, clearGroup: Bool = false) {
        var newInfos = [AppSessionInfoObj]()
        
        if clearGroup {
            newInfos = AppSession.sharedInstance._infos.filter {
                $0.group != key
            }
        } else {
            newInfos = AppSession.sharedInstance._infos.filter {
                $0.key != key
            }
        }

        AppSession.sharedInstance._infos = newInfos
    }
    
    /// Removes a single AppSessionInfoObj from the _infos array by key and group
    /// - Parameter key: Name used to reference the AppSessionInfoObj
    /// - Parameter clearGroup: True will remove all AppSessionInfoObj with group
    private static func removeInfoObjByKeyInGroup(key: String, groupName: String) {
        for (index, infoObj) in AppSession.sharedInstance._infos.enumerate() {
            if infoObj.group == groupName && infoObj.key == key {
                AppSession.sharedInstance._infos.removeAtIndex(index)
                return
            }
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