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
    
    private func tryHost(with ipAddress: String) {
        client = APIClient(ipAddress: ipAddress)
        client.fetchingSystemInfo() { result in
            switch result {
            case .failure(let error): print(error.reason)
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
        tryHost(with: device.ipAddress)
    }
    
    func lanScanDidFinishScanning(with status: MMLanScannerStatus) {
        self.isScanRunning = false
        print("SCAN finished")
    }
    
    func lanScanDidFailedToScan() {
        self.isScanRunning = false
         print("SCAN failed")
    }
    
    
}
