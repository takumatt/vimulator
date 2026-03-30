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
      NestedScrollTab()
        .tabItem { Label("Scroll", systemImage: "rectangle.split.2x2") }
      PagingTab()
        .tabItem { Label("Paging", systemImage: "rectangle.on.rectangle") }
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
  @State private var items = (1...30).map { "Item \($0)" }
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

// MARK: - Nested Scroll Tab

struct NestedScrollTab: View {
  private let sections = (1...8).map { "Section \($0)" }
  private let carouselItems = (1...12).map { "Card \($0)" }

  var body: some View {
    NavigationStack {
      ScrollView(.vertical) {
        VStack(alignment: .leading, spacing: 24) {
          ForEach(sections, id: \.self) { section in
            VStack(alignment: .leading, spacing: 8) {
              Text(section)
                .font(.headline)
                .padding(.horizontal)

              // Horizontal carousel inside vertical scroll
              ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                  ForEach(carouselItems, id: \.self) { item in
                    Button(item) {}
                      .frame(width: 100, height: 80)
                      .background(Color.blue.opacity(0.15), in: RoundedRectangle(cornerRadius: 10))
                  }
                }
                .padding(.horizontal)
              }
            }
          }
        }
        .padding(.vertical)
      }
      .navigationTitle("Nested Scroll")
    }
  }
}

// MARK: - Paging Tab

struct PagingTab: View {
  private let pages = ["Page 1", "Page 2", "Page 3", "Page 4"]

  var body: some View {
    NavigationStack {
      TabView {
        ForEach(pages, id: \.self) { page in
          ScrollView(.vertical) {
            VStack(spacing: 16) {
              Text(page).font(.title2).bold()
              ForEach(1...15, id: \.self) { i in
                Button("\(page) — Item \(i)") {}
                  .frame(maxWidth: .infinity)
                  .padding()
                  .background(Color.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
              }
            }
            .padding()
          }
          .tag(page)
        }
      }
      .tabViewStyle(.page)
      .indexViewStyle(.page(backgroundDisplayMode: .always))
      .navigationTitle("Paging")
    }
  }
}

#Preview {
  ContentView()
}
