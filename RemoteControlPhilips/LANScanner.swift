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
    private var checkedDevicesCount = 0
    
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
           tryHost(with: connectedDevices[index].ipAddress)
        }
    }
    
    private func tryHost(with ipAddress: String) {
        client = APIClient(ipAddress: ipAddress)
        client.fetchingSystemInfo() { result in
            switch result {
            case .failure(let error):
                self.checkedDevicesCount += 1
                print(error.reason)
                if self.checkedDevicesCount == self.connectedDevices.count {
                    self.checkedDevicesCount = 0
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
        print(device.ipAddress)
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
