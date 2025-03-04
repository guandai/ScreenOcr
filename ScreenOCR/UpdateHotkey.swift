import Carbon
import Cocoa

struct KeyInfo {
    var keyId: UInt32
    var name: String
    var keyPart: String
    var modifiers: [String]
}

class UpdateHotKey {
    static private var instance: UpdateHotKey?

    var rs: RegisterShortcut
    var cbMap: CbMap
    private var keyMap: [String: KeyInfo] = [:]

    private init(rs: RegisterShortcut, cbMap: CbMap) {
        self.rs = rs
        self.cbMap = cbMap
        setHotKeyMap(keyId: 1001, name: "run", keyPart: "", modifiers: [""])
        setHotKeyMap(keyId: 1002, name: "setting", keyPart: "", modifiers: [""])
    }

    static func initialize(rs: RegisterShortcut, cbMap: CbMap) {
        guard instance == nil else {
            print("⚠️ UpdateHotKey already initialized!")
            return
        }
        instance = UpdateHotKey(rs: rs, cbMap: cbMap)
    }

    static func shared() -> UpdateHotKey {
        guard let instance = instance else {
            fatalError("🚨 UpdateHotKey is not initialized! Call `initialize(rs:cbMap:)` first.")
        }
        return instance
    }

    func setHotKeyMap (keyId: UInt32, name: String, keyPart: String, modifiers: [String]) {
        keyMap[name] = KeyInfo( keyId: UInt32(keyId), name: name, keyPart: keyPart, modifiers: modifiers)
    }
    
    func getHotKeyMap () -> [String: KeyInfo] {
        return keyMap
    }
    
    func getKeyStr (_ keyName: String) -> String {
        if let keyInfo = keyMap[keyName] {
            let modifierPart = keyInfo.modifiers.joined(separator: "+")
            let keyPart = keyInfo.keyPart
            let result = modifierPart.isEmpty ? keyPart : (modifierPart + "+" + keyPart)
            return result
        }
        return "Not found name"
    }
    
    func getKeyParts(keyStr: String) -> (String, [String])? {
        print("> Changing keyId \(keyStr) to: \(keyStr)")
        let parts = keyStr.split(separator: "+").map { String($0).lowercased() }
        guard let keyPart = parts.last else {
            print("Invalid keyId combination.")
            return nil
        }
        let modifiers = parts.dropLast().map { String($0) }
        print("> Registering keyId with \(keyStr) key: \(keyPart) and modifiers: \(modifiers)")
        return (keyPart, modifiers)
    }

    func updateHotKey(keyName: String, tf: NSTextField) {
        let keyStr = tf.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if keyStr.isEmpty {
            print("! No keyId combination entered.")
            return
        }
        if let (keyPart, modifiers) = getKeyParts(keyStr: keyStr) {
            print("> updateHotKey call registerNewKeys for: \(keyStr)")
            registerNewKeys(keyName: keyName, keyPart: keyPart, modifiers: modifiers)
        } else {
            print("⚠️ Failed to parse key parts from: \(keyStr)")
        }
    }

    func registerNewKeys(keyName: String, keyPart: String, modifiers: [String]) {
        if let oldId = keyMap[keyName]?.keyId {
            print("> unregisterGlobalHotKey")
            rs.unregisterGlobalHotKey(oldId)
            keyMap.removeValue(forKey: keyName)
        } else {
            print("! Not unregisterGlobalHotKey")
        }

        guard let hotKeyIDEntry = globalCbMap[keyName],
              let newId = hotKeyIDEntry["keyId"] as? UInt32 else {
            print("⚠️ Error: keyId not found or invalid for key \(keyName)")
            return
        }

        print(">>> registerNewKeys call rs.registerGlobalHotKey for: \(keyName) \(keyPart)")
        rs.registerGlobalHotKey(
            keyName: keyName,
            callback: cbMap[keyName] ?? {},
            keyPart: keyPart,
            modifiers: Array(modifiers),
            keyId: newId
        )

        setHotKeyMap(keyId: newId, name: keyName, keyPart: keyPart, modifiers: modifiers)
    }
}
