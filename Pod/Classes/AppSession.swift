import Foundation

public typealias AppSessionGroup  = [String: Any]


/// ### AppSession
/// A simple wrapper around a dictionary type that allows one to easily share data
/// Singleton Pattern: http://krakendev.io/blog/the-right-way-to-write-a-singleton
open class AppSession {

    // MARK: Properties Static
    
    open static let sharedInstance = AppSession()
    
    // MARK: Properties FilePrivate
    
    fileprivate var _storage = AppSessionGroup()
    fileprivate var _groupNames = Set<String>()
    
    fileprivate struct AppSessionInfoObj: CustomStringConvertible {
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
    fileprivate var _infos = [AppSessionInfoObj]()
    
    open static var count: Int {
        return AppSession.sharedInstance._storage.count
    }
    
    open static var keys: Set<String> {
        return Set(Array(AppSession.sharedInstance._storage.keys))
    }
    
    open static var groups: Set<String> {
        return AppSession.sharedInstance._groupNames
    }
    
    // MARK: Initialization
    
    fileprivate init() {}

    // MARK: Methods
    
    /// Inserts a new key value pair into the AppSession
    /// - Parameter key: Name used to reference the session data
    /// - Parameter value: Data referenced by the key
    /// - Parameter group: Name used to lump key-value pairs together
    open static func set<T>(_ key: String, value: T, group: String = "") {
        if key.isEmpty { return }
        
        let theKey = key.lowercased()
        let theGroup = group.lowercased()

        
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
        
        AppSession.sharedInstance._infos.append(AppSessionInfoObj(key: theKey, valueType: String(describing: T.self), group: theGroup))
    }
    
    /// Returns a value from the AppSession based on the key
    /// - Parameter key: Name used to reference the session data
    /// - Returns: Data from the Session to be type-casted
    open static func get(_ key: String) -> Any {
        return AppSession.extract(key)
    }
    
    /// Performs a delete and retrieve from the Session based on the reference key
    /// - Parameter key: Name used to reference the session data
    /// - Returns: Data from the Session to be type-casted
    open static func pop(_ key: String) -> Any {
        let copy = AppSession.extract(key)
        AppSession.delete(key)
        return copy
    }
    
    /// Deletes all values from the session
    open static func clear() {
        AppSession.sharedInstance._infos = [AppSessionInfoObj]()
        AppSession.sharedInstance._storage = [:]
        AppSession.sharedInstance._groupNames = Set<String>()
    }
    
    /// Deletes a single value from the session based on the key
    /// - Parameter key: Name used to reference the session data
    open static func delete(_ key: String) {
        let theKey = key.lowercased()
        
        if AppSession.sharedInstance._groupNames.contains(theKey) {
            AppSession.removeInfoObj(theKey, clearGroup: true)
            AppSession.sharedInstance._groupNames.remove(theKey)
        } else {
            AppSession.removeInfoObj(theKey)
        }
        
        AppSession.sharedInstance._storage.removeValue(forKey: theKey)
    }
    
    /// Given a key, returns true if the session contains a value mapped to it.
    /// - Parameter key: Name used to reference the session data
    /// - Returns: Boolean
    open static func contains(_ key: String) -> Bool {
        return AppSession.keys.contains(key.lowercased())
    }
    
    /// Returns a DEBUG dump of the current values stored in AppSession
    open static func info() {
        print("📖 AppSession #DEBUG")
        for infoObj in AppSession.sharedInstance._infos {
            print(infoObj)
        }
    }
    
    // MARK: Private Methods
    
    /// Given a key, returns the Session data
    /// - Parameter key: Name used to reference the session data
    /// - Returns: Data from the Session to be type-casted
    fileprivate static func extract(_ key: String) -> Any {
        return unwrap(unwrap(AppSession.sharedInstance._storage[key.lowercased()]))
    }
    
    /// Inserts a new key value pair into the AppSession under the provided group name
    /// - Parameter key: Name used to reference the session data
    /// - Parameter value: Data referenced by the key
    /// - Parameter groupKey: Name used to lump key-value pairs together
    fileprivate static func appendGroupValue(_ key: String, value: Any, groupKey: String) {
        if AppSession.keys.contains(groupKey.lowercased()) {
            var currentGroup = (AppSession.sharedInstance._storage[groupKey.lowercased()] as? AppSessionGroup)
            currentGroup?[key] = value
            AppSession.sharedInstance._storage[groupKey.lowercased()] = currentGroup
        } else {
            var newGroup = AppSessionGroup()
            newGroup[key.lowercased()] = value
            AppSession.sharedInstance._storage[groupKey.lowercased()] = newGroup
        }
    }
    
    /// Removes a given AppSessionInfoObj from the _infos array via key lookup
    /// - Parameter key: Name used to reference the AppSessionInfoObj
    /// - Parameter clearGroup: True will remove all AppSessionInfoObj with group
    fileprivate static func removeInfoObj(_ key: String, clearGroup: Bool = false) {
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
    fileprivate static func removeInfoObjByKeyInGroup(_ key: String, groupName: String) {
        for (index, infoObj) in AppSession.sharedInstance._infos.enumerated() {
            if infoObj.group == groupName && infoObj.key == key {
                AppSession.sharedInstance._infos.remove(at: index)
                return
            }
        }
    }
    
    /// [http://stackoverflow.com/questions/27989094/how-to-unwrap-an-optional-value-from-any-type](http://stackoverflow.com/questions/27989094)
    fileprivate static func unwrap(_ any:Any) -> Any {
        let mi = Mirror(reflecting: any)
        if mi.displayStyle != .optional {
            return any
        }
        
        if mi.children.count == 0 { return NSNull() }
        let (_, some) = mi.children.first!
        return some
    }
}
