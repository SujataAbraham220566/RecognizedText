/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The main entry point for the app.
*/

import SwiftUI
import UIKit
import AVKit

@main
struct SampleTextScannerApp: App {
    @Environment(\.scenePhase) var scenePhase
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
}

