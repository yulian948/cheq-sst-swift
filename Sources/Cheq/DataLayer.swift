import Foundation
import os


/// Persistent data layer
public struct DataLayer {
    internal let log = Logger(subsystem: "Cheq", category: "DataLayer")
    internal let suiteName = "cheq.sst.datalayer"
    let data:UserDefaults?
    
    init() {
        self.data = UserDefaults(suiteName: suiteName)
    }
    
    
    /// returns all data present in data layer
    /// - Returns: dictionary of data, non-primitive data is returned as dictionaries
    public func all() -> [String: Any] {
        var result:[String: Any] = [:]
        if let data = data {
            let rawData = data.dictionaryRepresentation()
            for key in rawData.keys {
                if let existing = rawData[key] as? String,
                   let jsonData = existing.data(using: .utf8),
                   let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                    result[key] = json["value"]
                }
            }
        }
        return result
    }
    
    
    /// clears all values from the data layer
    public func clear() {
        data?.removePersistentDomain(forName: suiteName)
    }
    
    
    /// checks if key is present in data layer
    /// - Parameter key: key to check
    /// - Returns: true if key exists in data layer
    public func contains(_ key:String) -> Bool {
        return data?.object(forKey: key) != nil
    }
    
    
    /// gets value from data layer if present
    /// - Parameter key: key to retrieve
    /// - Returns: value if present, non-primitive data is returned as dictionaries
    public func get(_ key: String) -> Any? {
        var result: Any? = nil
        if let data = data,
           let existing = data.string(forKey: key),
           let jsonData = existing.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
            result = json["value"]
        }
        return result
    }
    
    
    /// stores a value for the key in the data layer
    /// - Parameters:
    ///   - key: key to store
    ///   - value: value to store
    public func add(key: String, value: Any) {
        guard let json = try? JSON.convertToJSONString(["value": value]) else {
            log.error("Failed to serialize value for key \(key, privacy: .public)")
            return
        }
        data?.set(json, forKey: key)
    }
    
    
    /// removes a key from data layer if present
    /// - Parameter key: key to remove
    /// - Returns: true if key exists in data layer and was removed
    public func remove(_ key: String) -> Bool {
        guard contains(key) else {
            return false
        }
        data?.removeObject(forKey: key)
        return true
    }
}
