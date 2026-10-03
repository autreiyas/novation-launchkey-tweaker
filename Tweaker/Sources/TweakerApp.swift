import SwiftUI

@main
struct TweakerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup("Launchkey Tweaker") {
            ContentView()
                .frame(minWidth: 380, minHeight: 420)
        }
        .windowStyle(.titleBar)
        .defaultSize(width: 780, height: 520)
        .commands {
            CommandGroup(replacing: .newItem) {}
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}
