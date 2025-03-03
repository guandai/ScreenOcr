import Carbon
import Cocoa

class UpdateHotkey {
    var rs : RegisterShortcut
    var cbMap : CbMap
    private var hotkeyMap: [String: UInt32] = [:]
    
    init(rs: RegisterShortcut, cbMap: CbMap){
        self.rs = rs
        self.cbMap = cbMap
    }
    
    func updateHotkey(name: String, tf: NSTextField) {
        print(22)
        let keyStr = tf.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if keyStr.isEmpty {
            print("No hotkey combination entered.")
            return
        }
        
        print("Changing hotkey to: \(keyStr)")
        // Split the input string by '+'.
        // The last element is assumed to be the key, the rest are modifiers.
        let parts = keyStr.split(separator: "+").map { String($0).lowercased() }
        guard let keyPart = parts.last else {
            print("Invalid hotkey combination.")
            return
        }

        let modifiers = parts.dropLast().map { String($0) }
        print("Registering hotkey with key: \(keyPart) and modifiers: \(modifiers)")
        
        if let oldHotkeyID = hotkeyMap[name] {
            rs.unregisterGlobalHotKey(oldHotkeyID)
        }
        let newHotkeyID: UInt32 = UInt32.random(in: 1000...9999)

        // Register the new hotkey
        rs.registerGlobalHotKey(
            key: keyPart,
            modifiers: Array(modifiers),
            callback: cbMap[name] ?? {},
            hotKeyIDNumber: newHotkeyID
        )

        // Store the new hotkey reference
        hotkeyMap[name] = newHotkeyID
    }
}
