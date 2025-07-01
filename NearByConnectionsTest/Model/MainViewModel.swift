import Foundation
import SwiftUI

class MainViewModel: ObservableObject, NearbyRepositoryCallback {
    private let repository: NearbyRepository
    
    @Published var connectState: String = ""
    @Published var receivedDataList: [(String, String)] = []
    
    init() {
        self.repository = NearbyRepository()
        self.repository.callback = self
    }
    
    func startAdvertise() {
        repository.startAdvertise()
    }
    
    func startDiscovery() {
        repository.startDiscovery()
    }
    
    func sendData(text: String) {
        repository.sendData(text: text)
    }
    
    func disconnectAll() {
        repository.disconnectAll()
    }
    
    func resetAll() {
        repository.resetAll()
        receivedDataList = []
    }
    
    // MARK: - NearbyRepositoryCallback
    func onConnectionStateChanged(state: String) {
        DispatchQueue.main.async {
            self.connectState = state
        }
    }
    
    func onDataReceived(data: String, fromEndpointId: String) {
        DispatchQueue.main.async {
            self.receivedDataList.append((fromEndpointId, data))
        }
    }
} 