//
//  ViewController.swift
//  BLECentralSample
//
//  Created by 高井　翔太 on 2018/04/19.
//  Copyright © 2018年 Shota Takai. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {
    var centralManager: CBCentralManager?
    var cmPowerIsOn = false
    var scanIsOn = false {
        didSet {
            if scanIsOn && cmPowerIsOn {
                print("start scan")
                centralManager?.scanForPeripherals(withServices: nil, options: nil)
            } else {
                print("stop scan")
                centralManager?.stopScan()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func tapButton(_ sender: UIButton) {
        scanIsOn = !scanIsOn
    }
}

extension ViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("state: \(central.state)")
        
        switch central.state {
        case .poweredOn:
            cmPowerIsOn = true
            print("central power is on")
        default:
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("発見したBLEデバイス: \(peripheral)")
    }
}
