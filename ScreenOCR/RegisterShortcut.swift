import Carbon
import Cocoa

class UserData {
    var keyName: String
    init(keyName: String) {
        self.keyName = keyName
    }
}

class RegisterShortcut {
    let keyboard = Keyboard()
    private var hotKeyIDRefs: [UInt32: EventHotKeyRef] = [:]

    func registerGlobalHotKey(
        keyName: String,
        callback: @escaping HotKeyCallback,
        keyStr: String,
        modifiers: [String],
        hotKeyID: UInt32
    ) {
        // Find the key code
        guard let keyCode = keyboard.keyCodeMap[keyStr.uppercased()] else {
            print("❌ registerGlobalHotKey: Unrecognized key '\(keyStr)'")
            return
        }

//        print("> register debugCallback \(keyName) \(keyStr)")

        // The reference that macOS gives us
        var hotKeyIDRef: EventHotKeyRef?

        // Set Callback
        setHotKeyCallback(
            keyName: keyName, hotKeyID: hotKeyID, callback: callback)

        installEventHandler(hotKeyID: hotKeyID)
        // Unmanaged<UserData>.fromOpaque(userDataPointer).release()

        //  Finally register the hotKeyID
        registerEventHotKey(
            modifiers: modifiers,
            keyCode: keyCode,
            keyStr: keyStr,
            hotKeyID: hotKeyID,
            hotKeyIDRef: &hotKeyIDRef
        )
    }

    func setHotKeyCallback(
        keyName: String, hotKeyID: UInt32, callback: @escaping HotKeyCallback
    ) {

        if globalCbMap[keyName] == nil {
            globalCbMap[keyName] = [:]  // Initialize if it doesn't exist
        }

        // Now safely update the "cb" key
        globalCbMap[keyName]?["cb"] = callback
        // print( "> Set Global hotKeyID setHotKeyCallback  \(hotKeyID) ")
    }

    func installEventHandler(hotKeyID: UInt32) {
//        print("> get in installEventHandler for \(hotKeyID)")
        let eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyReleased)
        )

        // Install our globalHotKeyHandler function pointer
        InstallEventHandler(
            GetApplicationEventTarget(),
            globalHotKeyHandler,  // <--- Pass the top-level function
            1,
            [eventType],
            nil,  // userData, if you want to pass something in
            nil
        )

    }

    func registerEventHotKey(
        modifiers: [String], keyCode: UInt32, keyStr: String, hotKeyID: UInt32,
        hotKeyIDRef: inout EventHotKeyRef?
    ) {

        let status = RegisterEventHotKey(
            keyCode,
            keyboard.carbonModifiers(forModifiers: modifiers),
            EventHotKeyID(signature: OSType(1234), id: hotKeyID),
            GetApplicationEventTarget(),
            0,
            &hotKeyIDRef
        )

        if status == noErr {
            hotKeyIDRefs[hotKeyID] = hotKeyIDRef  // Store the hotKeyID reference
            print(
                "> Registered hotKeyID: \(modifiers)+\(keyStr) (id=\(hotKeyID))"
            )
        } else {
            print("❌ Failed to register hotKeyID. Error code: \(status)")
        }
    }

    /// Unregister a global hotKeyID by ID
    func unregisterGlobalHotKey(_ hotKeyID: UInt32) {
        //        Unmanaged<UserData>.fromOpaque(userDataPointer).release()
        print("> start Unregistered hotKeyID with ID: \(hotKeyID)")
        
        if let hotKeyIDRef = hotKeyIDRefs[hotKeyID] {
            let status = UnregisterEventHotKey(hotKeyIDRef)
            if status == noErr {
                print("> Unregistered hotKeyID with ID: \(hotKeyID)")
                hotKeyIDRefs.removeValue(forKey: hotKeyID)  // Remove from dictionary
            } else {
                print(
                    "❌ Failed to unregister hotKeyID with ID: \(hotKeyID). Error code: \(status)"
                )
            }
        } else {
            print("⚠️ No hotKeyID found with ID: \(hotKeyID)")
        }
    }
}
