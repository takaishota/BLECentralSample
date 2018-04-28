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
    var peripheral: CBPeripheral?
    
    var cmPowerIsOn = false
    var scanIsOn = false {
        didSet {
            if scanIsOn && cmPowerIsOn {
                print("start scan")
                centralManager?.scanForPeripherals(withServices: nil, options: nil)
            } else {
                print("stop scan")
                centralManager?.stopScan()
                if let peripheral = peripheral {
                    centralManager?.cancelPeripheralConnection(peripheral)
                }
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
        
        self.peripheral = peripheral
        
        if let peripheral = self.peripheral {
            centralManager?.connect(peripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("⭕️ connection is success")
        
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("‼️ connection failed")
    }
}

extension ViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            return
        }
        print("\(services.count)個のサービスを発見！ \(services)")
        services.forEach { service in
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            return
        }
        print("\(characteristics.count)個のキャラクタリスティックを発見！ \(characteristics)")
        characteristics
            .filter { $0.properties == .read }
            .forEach { peripheral.readValue(for: $0) }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.uuid.isEqual(CBUUID(string: "2A38")) {
            if let value = characteristic.value {
                print("HEART RATE: \(value[0])")
                print("読み出し成功！ service uuid: \(characteristic.service.uuid), characteristic uuid: \(characteristic.uuid), value: \(String(describing: value[0]))")
            }
        }
    }
}
