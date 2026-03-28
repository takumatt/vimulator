//
//  VimulatorExampleApp.swift
//  VimulatorExample
//
//  Created by Takuma Matsushita on 2026/03/29.
//

import SwiftUI
import Vimulator

@main
struct VimulatorExampleApp: App {
    init() {
        Vimulator.shared.style = .dark
        Vimulator.shared.install()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
