//
//  BackendConnector.swift
//  BTCCandleStickChart
//
//  Created by Igor Kishik on 22.03.2020.
//  Copyright © 2020 Igor Kishik. All rights reserved.
//

import Foundation
import Starscream

protocol SocketListener {
    func websocketDidConnect()
    func websocketDidDisconnect()
    func websocketDidReceiveText(_ message: String)
}

class BackendConnector: WebSocketDelegate {
    
    static let shared = BackendConnector()
    
    private var socket:WebSocket!
    private var isConnected: Bool = false
    
    private var listeners: [SocketListener] = []
    
    func listen(listener: SocketListener) {
        listeners.append(listener)
    }
    
    func connect() {
        
        let server_url = "wss://quotes.eccalls.mobi:18400"
        let url = URL(string: server_url)
        if let url = url {
            let request = URLRequest(url: url)
            socket = WebSocket(request: request,certPinner: FoundationSecurity(allowSelfSigned: true) )
            socket.delegate = self
            socket.connect()
        }
    }
    
    func disconnect() {
        if (socket != nil && isConnected) {
            socket.disconnect(closeCode: CloseCode.normal.rawValue)
            socket.delegate = nil
        }
    }
    
    func reconnect() {
         disconnect()
         connect()
     }
    
    func sendMessage(_ message: String) {
        if isConnected {
            socket.write(string: message) {
                print("SEND MESSAGE")
            }
        }
    }
    
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            isConnected = true
            print("websocket is connected: \(headers)")
            listeners.forEach({ $0.websocketDidConnect() })
        case .disconnected(let reason, let code):
            isConnected = false
            print("websocket is disconnected: \(reason) with code: \(code)")
            listeners.forEach({ $0.websocketDidDisconnect() })
            if code != CloseCode.normal.rawValue {
                reconnect()
            }
        case .text(let string):
            print("Received text: \(string)")
            listeners.forEach({ $0.websocketDidReceiveText(string) })
        case .binary(let data):
            print("Received data: \(data.count)")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viablityChanged(_):
            break
        case .reconnectSuggested(_):
            listeners.forEach({ $0.websocketDidDisconnect() })
            reconnect()
        case .cancelled:
            listeners.forEach({ $0.websocketDidDisconnect() })
            isConnected = false
        case .error(let error):
            listeners.forEach({ $0.websocketDidDisconnect() })
            isConnected = false
            handleError(error)
        }
    }
    
    func handleError(_ error: Error?) {
        if let e = error as? WSError {
            print("websocket encountered an error: \(e.message)")
        } else if let e = error {
            print("websocket encountered an error: \(e.localizedDescription)")
        } else {
            print("websocket encountered an error")
        }
        reconnect()
    }
    
}
