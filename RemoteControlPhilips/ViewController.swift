//
//  ViewController.swift
//  RemoteControlPhilips
//
//  Created by Daian Aiziatov on 12/01/2019.
//  Copyright © 2019 Daian Aiziatov. All rights reserved.
//

import UIKit

class ViewController: UIViewController, AlertDisplayable {

    private var scanner = LANScanner()
    private var myContext = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scanner.addObserver(self, forKeyPath: "isScanRunning", options: .new, context: &myContext)
    }
    
    @IBAction func scanTapped(_ sender: UIButton) {
        self.startLoadingView()
        scanner.scanForPhillipsTV()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if (context == &myContext) {
            
            switch keyPath! {
            case "isScanRunning":
                let isScanRunning = change?[.newKey] as! BooleanLiteralType
                if !isScanRunning {
                    self.dismissLoadingView()
                    self.scanner.getResultOfScanning() { result in
                        switch result {
                        case .failure(let error):
                            DispatchQueue.main.async {
                                let title = "Warning"
                                let action = UIAlertAction(title: "Ok", style: .default)
                                self.displayAlert(with: title , message: error.reason, actions: [action])
                            }
                        case .success(let data):
                            DispatchQueue.main.async {
                                let title = "Success"
                                let action = UIAlertAction(title: "Ok", style: .default)
                                let message = "Name: \(data.name)\nIP address: \(data.ipAddress!)"
                                self.displayAlert(with: title , message: message, actions: [action])
                            }
                        }
                    }
                    
                }
            default:
                print("Not valid key for observing")
            }
            
        }
    }


}

