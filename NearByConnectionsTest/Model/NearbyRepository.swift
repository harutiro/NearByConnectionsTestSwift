import Foundation

protocol NearbyRepositoryCallback: AnyObject {
    func onConnectionStateChanged(state: String)
    func onDataReceived(data: String, fromEndpointId: String)
}

class NearbyRepository: NSObject {
    weak var callback: NearbyRepositoryCallback?
    private let nickName: String
    private let serviceId: String
    private var remoteEndpointIds: Set<String> = []
    private var isAdvertising = false
    private var isDiscovering = false
    
    init(nickName: String = "harutiro",
         serviceId: String = "net.harutiro.nearbyconnectionsapitest") {
        self.nickName = nickName
        self.serviceId = serviceId
        super.init()
    }
    
    func startAdvertise() {
        isAdvertising = true
        callback?.onConnectionStateChanged(state: "広告開始")
        
        // シミュレーション: 2秒後に接続を模擬
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.simulateConnection()
        }
    }
    
    func startDiscovery() {
        isDiscovering = true
        callback?.onConnectionStateChanged(state: "発見開始")
        
        // シミュレーション: 3秒後にデバイス発見を模擬
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.simulateDiscovery()
        }
    }
    
    func stopAdvertising() {
        isAdvertising = false
        callback?.onConnectionStateChanged(state: "広告停止")
    }
    
    func stopDiscovery() {
        isDiscovering = false
        callback?.onConnectionStateChanged(state: "発見停止")
    }
    
    func disconnectAll() {
        remoteEndpointIds.removeAll()
        isAdvertising = false
        isDiscovering = false
        callback?.onConnectionStateChanged(state: "全端末と切断")
    }
    
    func resetAll() {
        stopAdvertising()
        stopDiscovery()
        disconnectAll()
        callback?.onConnectionStateChanged(state: "全リセット")
    }
    
    func sendData(text: String) {
        guard !remoteEndpointIds.isEmpty else {
            callback?.onConnectionStateChanged(state: "送信先なし")
            return
        }
        
        callback?.onConnectionStateChanged(state: "データ送信: \(remoteEndpointIds.count)台")
        
        // シミュレーション: 自分に送り返す
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.callback?.onDataReceived(data: "エコー: \(text)", fromEndpointId: "simulator_device")
        }
    }
    
    // MARK: - シミュレーション用メソッド
    private func simulateConnection() {
        let simulatedEndpointId = "simulated_endpoint_\(Int.random(in: 1000...9999))"
        remoteEndpointIds.insert(simulatedEndpointId)
        callback?.onConnectionStateChanged(state: "接続成功: \(simulatedEndpointId)")
    }
    
    private func simulateDiscovery() {
        callback?.onConnectionStateChanged(state: "エンドポイント発見: simulated_device")
        
        // 自動で接続シミュレーション
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.simulateConnection()
        }
    }
} 