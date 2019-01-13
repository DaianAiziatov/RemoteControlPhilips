//
//  LANScanner.swift
//  RemoteControlPhilips
//
//  Created by Daian Aiziatov on 13/01/2019.
//  Copyright © 2019 Daian Aiziatov. All rights reserved.
//

import Foundation

class LANScanner: NSObject {
    
    @objc dynamic var isScanRunning : BooleanLiteralType = false
    private var myContext = 0
    private var connectedDevices = [MMDevice]()
    
    private var client: APIClient!
    private var tvInfo: SystemInfo?
    
    private lazy var lanScanner: MMLANScanner = {
        return MMLANScanner(delegate:self)
    }()
    
    func scanForPhillipsTV() {
        self.isScanRunning = true
        lanScanner.start()
    }
    
    func getResultOfScanning(completion: @escaping (Result<SystemInfo, DataResponseError>) -> Void) {
        guard let tvInfo = self.tvInfo else {
            completion(Result.failure(DataResponseError.noTVinNetwork))
            return
        }
        completion(Result.success(tvInfo))
    }
    
    private func tryConnectedDevices() {
        for index in 0..<connectedDevices.count {
            if index == (connectedDevices.count - 1) {
                tryHost(with: connectedDevices[index].ipAddress, isLast: true)
            } else {
                tryHost(with: connectedDevices[index].ipAddress, isLast: false)
            }
        }
    }
    
    private func tryHost(with ipAddress: String, isLast: Bool) {
        client = APIClient(ipAddress: ipAddress)
        client.fetchingSystemInfo() { result in
            switch result {
            case .failure(let error):
                print(error.reason)
                if isLast {
                    self.isScanRunning = false
                    print("Process is complited")
                }
            case .success(let response):
                self.tvInfo = response
                print("SUCCESS: \(response.ipAddress!)")
                self.lanScanner.stop()
                self.isScanRunning = false
            }
        }
    }
    
    
}

extension LANScanner: MMLANScannerDelegate {
    
    func lanScanDidFindNewDevice(_ device: MMDevice!) {
        if(!self.connectedDevices.contains(device)) {
            self.connectedDevices.append(device)
        }

    }
    
    func lanScanDidFinishScanning(with status: MMLanScannerStatus) {
        print("SCAN finished, TryingHosts Started")
        self.tryConnectedDevices()
    }
    
    func lanScanDidFailedToScan() {
        self.isScanRunning = false
        print("SCAN failed")
    }
    
    
}
