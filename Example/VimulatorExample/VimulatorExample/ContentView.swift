//
//  ContentView.swift
//  VimulatorExample
//
//  Created by Takuma Matsushita on 2026/03/29.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            ButtonsTab()
                .tabItem { Label("Buttons", systemImage: "hand.tap") }
            ListTab()
                .tabItem { Label("List", systemImage: "list.bullet") }
            FormTab()
                .tabItem { Label("Form", systemImage: "slider.horizontal.3") }
        }
    }
}

// MARK: - Buttons Tab

struct ButtonsTab: View {
    @State private var log: [String] = []

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                ForEach(["Primary Action", "Secondary Action", "Destructive"], id: \.self) { title in
                    Button(title) { log.append("\(title) tapped") }
                        .buttonStyle(.borderedProminent)
                }

                Divider()

                NavigationLink("Go to Detail") {
                    Text("Detail View")
                        .navigationTitle("Detail")
                }
                .buttonStyle(.bordered)

                if !log.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Log").font(.caption).foregroundStyle(.secondary)
                        ForEach(log.indices, id: \.self) { i in
                            Text("• \(log[i])").font(.caption2)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding()
            .navigationTitle("Buttons")
        }
    }
}

// MARK: - List Tab

struct ListTab: View {
    @State private var items = (1...8).map { "Item \($0)" }
    @State private var selected: String?

    var body: some View {
        NavigationStack {
            List(items, id: \.self, selection: $selected) { item in
                NavigationLink(item) {
                    Text("\(item) Detail")
                        .navigationTitle(item)
                }
            }
            .navigationTitle("List")
        }
    }
}

// MARK: - Form Tab

struct FormTab: View {
    @State private var name = ""
    @State private var enabled = true
    @State private var speed = 0.5

    var body: some View {
        NavigationStack {
            Form {
                Section("Input") {
                    TextField("Name", text: $name)
                    Toggle("Enabled", isOn: $enabled)
                    Slider(value: $speed, label: { Text("Speed") })
                }
                Section {
                    Button("Submit") {}
                    Button("Reset", role: .destructive) {
                        name = ""
                        enabled = true
                        speed = 0.5
                    }
                }
            }
            .navigationTitle("Form")
        }
    }
}

#Preview {
    ContentView()
}
