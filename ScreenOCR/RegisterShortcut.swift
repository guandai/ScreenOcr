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
        keyPart: String,
        modifiers: [String],
        keyId: UInt32
    ) {
        // Find the key code
        guard let keyCode = keyboard.keyCodeMap[keyPart.uppercased()] else {
            print("❌ registerGlobalHotKey: Unrecognized key '\(keyPart)'")
            return
        }

//        print("> register debugCallback \(keyName) \(keyPart)")

        // The reference that macOS gives us
        var hotKeyIDRef: EventHotKeyRef?

        // Set Callback
        setHotKeyCallback(
            keyName: keyName, keyId: keyId, callback: callback)

        installEventHandler(keyId: keyId)
        // Unmanaged<UserData>.fromOpaque(userDataPointer).release()

        //  Finally register the keyId
        registerEventHotKey(
            modifiers: modifiers,
            keyCode: keyCode,
            keyPart: keyPart,
            keyId: keyId,
            hotKeyIDRef: &hotKeyIDRef
        )
    }

    func setHotKeyCallback(
        keyName: String, keyId: UInt32, callback: @escaping HotKeyCallback
    ) {

        if globalCbMap[keyName] == nil {
            globalCbMap[keyName] = [:]  // Initialize if it doesn't exist
        }

        // Now safely update the "cb" key
        globalCbMap[keyName]?["cb"] = callback
        // print( "> Set Global keyId setHotKeyCallback  \(keyId) ")
    }

    func installEventHandler(keyId: UInt32) {
//        print("> get in installEventHandler for \(keyId)")
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
        modifiers: [String], keyCode: UInt32, keyPart: String, keyId: UInt32,
        hotKeyIDRef: inout EventHotKeyRef?
    ) {

        let status = RegisterEventHotKey(
            keyCode,
            keyboard.carbonModifiers(forModifiers: modifiers),
            EventHotKeyID(signature: OSType(1234), id: keyId),
            GetApplicationEventTarget(),
            0,
            &hotKeyIDRef
        )

        if status == noErr {
            hotKeyIDRefs[keyId] = hotKeyIDRef  // Store the keyId reference
            print(
                "> Registered keyId: \(modifiers)+\(keyPart) (id=\(keyId))"
            )
        } else {
            print("❌ Failed to register keyId. Error code: \(status)")
        }
    }

    /// Unregister a global keyId by ID
    func unregisterGlobalHotKey(_ keyId: UInt32) {
        //        Unmanaged<UserData>.fromOpaque(userDataPointer).release()
        print("> start Unregistered keyId with ID: \(keyId)")
        
        if let hotKeyIDRef = hotKeyIDRefs[keyId] {
            let status = UnregisterEventHotKey(hotKeyIDRef)
            if status == noErr {
                print("> Unregistered keyId with ID: \(keyId)")
                hotKeyIDRefs.removeValue(forKey: keyId)  // Remove from dictionary
            } else {
                print(
                    "❌ Failed to unregister keyId with ID: \(keyId). Error code: \(status)"
                )
            }
        } else {
            print("⚠️ No keyId found with ID: \(keyId)")
        }
    }
}
