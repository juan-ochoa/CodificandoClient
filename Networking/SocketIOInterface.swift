//
//  SocketIOInterface.swift
//  CodificandoClient
//
//  Created by Juan Ochoa on 6/10/18.
//  Copyright © 2018 Juan Ochoa. All rights reserved.
//

import Foundation
import SocketIO

public class SocketIOInterface
{
    let manager = SocketManager(socketURL: URL(string: Configuration.ServerUrl)!)

    func StartCommunication(callBackFunction: @escaping ([Player]) -> Void, namespace: String?, playerData: NewPlayerData)
    {
        var socket = manager.defaultSocket
        if let nps = namespace
        {
            socket = manager.socket(forNamespace: nps)
        }

        socket.on("error") { data, ack in
            print("Connection error: \(data)")
        }

        socket.on("connect") { data, ack in
            print("Connected")

            socket.emit("new player", playerData)
        }

        socket.on("state") { data, ack in

            var result = [Player]()

            let dataArray = data as NSArray
            let players = dataArray[0] as! NSDictionary

            for (key, value) in players
            {
                let socketId = key as! String

                let playerPosition = value as! NSDictionary
                let x = playerPosition["x"] as! Int32
                let y = playerPosition["y"] as! Int32

                result.append(Player(id: socketId, x: Int(x), y: Int(y)))
            }

            callBackFunction(result)
        }

        socket.connect()
    }
}
