import Carbon
import Cocoa

class RegisterShortcut {
    let keyboard = Keyboard()
    private var hotKeyRefs: [UInt32: EventHotKeyRef] = [:]

    func setHotKeyCallback(hkID: UInt32, callback: @escaping HotKeyCallback) {
        print("🔥 Global hotkey triggered: executing screenshot capture!")
        globalCallbackMap[hkID] = callback
    }

    func registerGlobalHotKey(
        key: String,
        modifiers: [String],
        callback: @escaping HotKeyCallback,
        hotKeyIDNumber: UInt32,
        signature: OSType = OSType(1234)
    ) {
        // Find the key code
        guard let keyCode = keyboard.keyCodeMap[key.uppercased()] else {
            print("❌ registerGlobalHotKey: Unrecognized key '\(key)'")
            return
        }

        // Set Callback
        setHotKeyCallback(hkID: hotKeyIDNumber, callback: callback)

        // Build Carbon modifier flags
        let carbonFlags = keyboard.carbonModifiers(forModifiers: modifiers)

        // Create the hotkey identifier
        let hotKeyID = EventHotKeyID(signature: signature, id: hotKeyIDNumber)

        // The reference that macOS gives us
        var hotKeyRef: EventHotKeyRef?

        // The event types we care about (a pressed hotkey)
        let eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: OSType(kEventHotKeyPressed)
        )
        print(6)
        // Install our globalHotKeyHandler function pointer
        //    Instead of an inline Swift closure.
        InstallEventHandler(
            GetApplicationEventTarget(),
            globalHotKeyHandler,  // <--- Pass the top-level function
            1,
            [eventType],
            nil,  // userData, if you want to pass something in
            nil
        )

        // 7. Finally register the hotkey
        let status = RegisterEventHotKey(
            keyCode, carbonFlags, hotKeyID, GetApplicationEventTarget(), 0,
            &hotKeyRef)

        if status == noErr {
            hotKeyRefs[hotKeyIDNumber] = hotKeyRef  // Store the hotkey reference
            print(
                "✅ Registered hotkey: \(modifiers)+\(key) (id=\(hotKeyIDNumber), sig=\(signature))"
            )
        } else {
            print("❌ Failed to register hotkey. Error code: \(status)")
        }
    }

    /// Unregister a global hotkey by ID
    func unregisterGlobalHotKey(_ hotKeyIDNumber: UInt32) {
        if let hotKeyRef = hotKeyRefs[hotKeyIDNumber] {
            let status = UnregisterEventHotKey(hotKeyRef)
            if status == noErr {
                print("✅ Unregistered hotkey with ID: \(hotKeyIDNumber)")
                hotKeyRefs.removeValue(forKey: hotKeyIDNumber)  // Remove from dictionary
            } else {
                print(
                    "❌ Failed to unregister hotkey with ID: \(hotKeyIDNumber). Error code: \(status)"
                )
            }
        } else {
            print("⚠️ No hotkey found with ID: \(hotKeyIDNumber)")
        }
    }
}
