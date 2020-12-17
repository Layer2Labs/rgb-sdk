//
//  RGBController.swift
//  RGBController
//
//  Created by Maxim Orlovsky on 12/16/20.
//

import Foundation
import rgblib

public struct RGBError: Error {
    let message: String
    
    init!(_ res: CResult) {
        guard res.result.rawValue != 0 else {
            return nil
        }
        let cstr = res.inner.ptr.load(as: UnsafePointer<CChar>.self)
        self.message = String(cString: cstr)
    }
}

open class RGB20Controller {
    private var client: COpaqueStruct
    let network: String
    let dataDir: String
    
    public init(network: String = "testnet") throws {
        self.network = network
        self.dataDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.path

        let client = rgb_node_run(self.network, self.dataDir)
        
        guard client.result.rawValue == 0 else {
            throw RGBError(client)
        }
        
        self.client = client.inner
    }
    
    open func createAsset(ticker: String, name: String, description: String? = nil, precision: UInt8 = 8, allocations: String = "[]") throws {
        // let allocations = String(data: try JSONEncoder().encode(allocations), encoding: .utf8)
        
        try withUnsafePointer(to: self.client) { client in
            let res = rgb_node_fungible_issue(
                client,
                network,
                ticker,
                name,
                description,
                precision,
                allocations,
                "[]", "null", "null")
            guard res.result.rawValue == 0 else {
                throw RGBError(res)
            }
        }
    }
}
