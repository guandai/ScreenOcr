import Carbon
import Cocoa

class UpdateHotKey {
    static let shared = UpdateHotKey(rs: RegisterShortcut(), cbMap: CbMap())
    
    var rs : RegisterShortcut
    var cbMap : CbMap
    private var hotKeyIDMap: [String: UInt32] = [:]
    
    init(rs: RegisterShortcut, cbMap: CbMap){
        self.rs = rs
        self.cbMap = cbMap
    }
    
    func getKeyparts (keyStr: String) -> (String, [String])? {
        // Extract the new key, modifiers, etc. from the text field (tf)
        print("> Changing hotKeyID \(keyStr) to: \(keyStr)")
        let parts = keyStr.split(separator: "+").map { String($0).lowercased() }
        guard let keyPart = parts.last else {
            print("Invalid hotKeyID combination.")
            return nil
        }

        let modifiers = parts.dropLast().map { String($0) }
        print("> Registering hotKeyID with \(keyStr) key: \(keyPart) and modifiers: \(modifiers)")
        
        return (keyPart, modifiers)
    }
    
    func updateHotKey(keyName: String, tf: NSTextField) {
        let keyStr = tf.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if keyStr.isEmpty {
            print("! No hotKeyID combination entered.")
            return
        }
        
        if let (keyPart, modifiers) = getKeyparts(keyStr: keyStr) {
            print("> updateHotKey call registerNewKeys for: \(keyStr)")
            registerNewKeys(keyName: keyName, keyPart: keyPart, modifiers: modifiers )
        } else {
            print("⚠️ Failed to parse key parts from: \(keyStr)")
        }
    }
    
    func registerNewKeys(keyName: String, keyPart: String, modifiers: [String] ) {
        // 2. Deregister (unregister) that old hotKeyID
        if let oldhotKeyID = hotKeyIDMap[keyName] {
            print("> unregisterGlobalHotKey")
            rs.unregisterGlobalHotKey(oldhotKeyID)
            hotKeyIDMap.removeValue(forKey: keyName)
        } else {
            print("! Not unregisterGlobalHotKey")
        }
        
        guard let hotKeyIDEntry = globalCbMap[keyName],
              let newhotKeyID = hotKeyIDEntry["hotKeyID"] as? UInt32 else {
            print("⚠️ Error: hotKeyID not found or invalid for key \(keyName)")
            return
        }

        print(">>> registerNewKeys call rs.registerGlobalHotKey for: \(keyName) \(keyPart)")
        // Register the new hotKeyID
        rs.registerGlobalHotKey(
            keyName: keyName,
            callback: cbMap[keyName] ?? {},
            keyStr: keyPart,
            modifiers: Array(modifiers),
            hotKeyID: newhotKeyID
        )

        hotKeyIDMap[keyName] = newhotKeyID
    }
}
