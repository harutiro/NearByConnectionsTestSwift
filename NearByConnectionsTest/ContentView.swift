//
//  ContentView.swift
//  NearByConnectionsTest
//
//  Created by はるちろ on R 7/07/01.
//

import SwiftUI
import NearbyConnections

struct ContentView: View {
    @StateObject private var model = Model()
    @State private var showingSettings = false
    @State private var messageToSend = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // ヘッダー情報
                VStack {
                    Text("Nearby Connections")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("デバイス名: \(model.endpointName)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                // 制御ボタン
                HStack(spacing: 20) {
                    VStack {
                        Button(action: {
                            model.isAdvertisingEnabled.toggle()
                        }) {
                            VStack {
                                Image(systemName: model.isAdvertisingEnabled ? "radio.fill" : "radio")
                                    .font(.title2)
                                Text("広告")
                                    .font(.caption)
                            }
                            .foregroundColor(model.isAdvertisingEnabled ? .green : .gray)
                        }
                    }
                    
                    VStack {
                        Button(action: {
                            model.isDiscoveryEnabled.toggle()
                        }) {
                            VStack {
                                Image(systemName: model.isDiscoveryEnabled ? "magnifyingglass.circle.fill" : "magnifyingglass.circle")
                                    .font(.title2)
                                Text("発見")
                                    .font(.caption)
                            }
                            .foregroundColor(model.isDiscoveryEnabled ? .blue : .gray)
                        }
                    }
                    
                    VStack {
                        Button(action: {
                            showingSettings = true
                        }) {
                            VStack {
                                Image(systemName: "gearshape")
                                    .font(.title2)
                                Text("設定")
                                    .font(.caption)
                            }
                            .foregroundColor(.orange)
                        }
                    }
                }
                .padding(.horizontal)
                
                // タブビュー
                TabView {
                    // 発見されたデバイスタブ
                    DiscoveredDevicesView(model: model)
                        .tabItem {
                            Image(systemName: "antenna.radiowaves.left.and.right")
                            Text("発見されたデバイス")
                        }
                    
                    // 接続要求タブ
                    ConnectionRequestsView(model: model)
                        .tabItem {
                            Image(systemName: "person.crop.circle.badge.questionmark")
                            Text("接続要求")
                        }
                        .badge(model.requests.count > 0 ? model.requests.count : 0)
                    
                    // 接続されたデバイスタブ
                    ConnectedDevicesView(model: model)
                        .tabItem {
                            Image(systemName: "link")
                            Text("接続済み")
                        }
                        .badge(model.connections.count > 0 ? model.connections.count : 0)
                }
            }
            .navigationTitle("Nearby Connections")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("設定") {
                        showingSettings = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(model: model)
        }
    }
}

struct DiscoveredDevicesView: View {
    @ObservedObject var model: Model
    
    var body: some View {
        NavigationView {
            List {
                if model.endpoints.isEmpty {
                    Text("発見されたデバイスがありません")
                        .foregroundColor(.secondary)
                        .italic()
                } else {
                    ForEach(model.endpoints) { endpoint in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(endpoint.endpointName)
                                    .font(.headline)
                                Text("ID: \(endpoint.endpointID)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button("接続") {
                                model.requestConnection(to: endpoint.endpointID)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("発見されたデバイス")
        }
    }
}

struct ConnectionRequestsView: View {
    @ObservedObject var model: Model
    
    var body: some View {
        NavigationView {
            List {
                if model.requests.isEmpty {
                    Text("接続要求がありません")
                        .foregroundColor(.secondary)
                        .italic()
                } else {
                    ForEach(model.requests) { request in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(request.endpointName)
                                        .font(.headline)
                                    Text("ID: \(request.endpointID)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                            
                            Text("認証コード: \(request.pin)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                            
                            HStack {
                                Button("拒否") {
                                    request.shouldAccept(false)
                                }
                                .buttonStyle(.bordered)
                                .foregroundColor(.red)
                                
                                Spacer()
                                
                                Button("承認") {
                                    request.shouldAccept(true)
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("接続要求")
        }
    }
}

struct ConnectedDevicesView: View {
    @ObservedObject var model: Model
    @State private var messageToSend = ""
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    if model.connections.isEmpty {
                        Text("接続されたデバイスがありません")
                            .foregroundColor(.secondary)
                            .italic()
                    } else {
                        ForEach(model.connections) { connection in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(connection.endpointName)
                                            .font(.headline)
                                        Text("ID: \(connection.endpointID)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Button("切断") {
                                        model.disconnect(from: connection.endpointID)
                                    }
                                    .buttonStyle(.bordered)
                                    .foregroundColor(.red)
                                    .controlSize(.small)
                                }
                                
                                if !connection.payloads.isEmpty {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("ペイロード履歴:")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                        
                                        ForEach(connection.payloads.prefix(3), id: \.id) { payload in
                                            HStack {
                                                Image(systemName: payload.isIncoming ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                                                    .foregroundColor(payload.isIncoming ? .green : .blue)
                                                
                                                Text("\(payload.type)")
                                                    .font(.caption)
                                                
                                                Spacer()
                                                
                                                Text(statusText(for: payload.status))
                                                    .font(.caption)
                                                    .foregroundColor(statusColor(for: payload.status))
                                            }
                                        }
                                    }
                                    .padding(.top, 4)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                
                // メッセージ送信セクション
                if !model.connections.isEmpty {
                    VStack {
                        Divider()
                        
                        HStack {
                            Button("全員にメッセージ送信") {
                                let endpointIDs = model.connections.map { $0.endpointID }
                                model.sendBytes(to: endpointIDs)
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(model.connections.isEmpty)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("接続済みデバイス")
        }
    }
    
    private func statusText(for status: Payload.Status) -> String {
        switch status {
        case .success:
            return "完了"
        case .failure:
            return "失敗"
        case .canceled:
            return "キャンセル"
        case .inProgress:
            return "進行中"
        }
    }
    
    private func statusColor(for status: Payload.Status) -> Color {
        switch status {
        case .success:
            return .green
        case .failure:
            return .red
        case .canceled:
            return .orange
        case .inProgress:
            return .blue
        }
    }
}

struct SettingsView: View {
    @ObservedObject var model: Model
    @Environment(\.dismiss) private var dismiss
    @State private var tempEndpointName: String = ""
    @State private var tempStrategy: Strategy = .cluster
    
    var body: some View {
        NavigationView {
            Form {
                Section("デバイス設定") {
                    HStack {
                        Text("デバイス名")
                        Spacer()
                        TextField("デバイス名", text: $tempEndpointName)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 200)
                    }
                }
                
                Section("接続戦略") {
                    Picker("戦略", selection: $tempStrategy) {
                        Text("クラスター").tag(Strategy.cluster)
                        Text("スター").tag(Strategy.star)
                        Text("ポイントトゥポイント").tag(Strategy.pointToPoint)
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("サービス情報") {
                    HStack {
                        Text("サービスID")
                        Spacer()
                        Text(Config.serviceId)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("設定")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        model.endpointName = tempEndpointName
                        model.strategy = tempStrategy
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            tempEndpointName = model.endpointName
            tempStrategy = model.strategy
        }
    }
}

#Preview {
    ContentView()
}
