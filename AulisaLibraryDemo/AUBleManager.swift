//
//  AUBleManager.swift
//  AulisaLibraryDemo
//
//  Created by Li Yun Jung on 2020/9/10.
//  Copyright © 2020 Aulisa. All rights reserved.
//


import Foundation
import CoreBluetooth
import AUOximeter


//background queue for ble manager
let bleQueue = DispatchQueue(label: "com.aulisa.ga1000.ble")

public class AUBleManager : NSObject {
    
    
    public static let UUID_S_DeviceInformation = "180A"
    public static let UUID_C_SystemID = "2A23"
    
    //MARK:- Variables
    
    public static let shared = AUBleManager()
    fileprivate var scanTimer : Timer?
    fileprivate var centralManager : CBCentralManager!
    public var delegate : AUBleManagerDelegate? {
        didSet {
            self.delegate?.didBLEUpdateState(manager: self, state: centralManager.state)
        }
    }
    public var oxiDelegate : AUOximeterDataDelegate?
    
    fileprivate var oxiDevice : AUOximeter?
    fileprivate var macList : [String] = []
    fileprivate var disposedUUID : [String] = []
    fileprivate var currentPeripheral : CBPeripheral?
    fileprivate var systemIDCharacteristic : CBCharacteristic?
    
    private override init(){
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: bleQueue)
    }
    
    
    //MARK:- Function
    /// if ble status is not on return false
    public func startScan(macList : [String]) -> Bool{
        
        self.macList = macList
        centralManager.scanForPeripherals(withServices:nil, options: nil)
        scanTimer = Timer.scheduledTimer(timeInterval: 90.0, target: self, selector: #selector(self.scanTimerFunc), userInfo: nil, repeats: false)
        NSLog("Start scan")
        return true
    }
    
    @objc fileprivate func scanTimerFunc(){
        NSLog("SCAN TIMEOUT")
        self.delegate?.isTimeOut(manager: self)
        self.stopScan()
    }
    
    public func stopScan(){
        if (currentPeripheral != nil){
            centralManager.cancelPeripheralConnection(currentPeripheral!)
        }
        centralManager.stopScan()
        scanTimer?.invalidate()
        scanTimer = nil
        oxiDevice = nil
        currentPeripheral = nil
        systemIDCharacteristic = nil
        disposedUUID = []
        macList = []
    }
    
    public func cancelConnection(){
        scanTimer?.invalidate()
    }
    
    
    
}


extension AUBleManager : CBCentralManagerDelegate {
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        var stateMessage = "BLE Update State : "
        switch central.state{
        case .poweredOff:
            stateMessage += "PoweredOff"
        case .poweredOn:
            stateMessage += "PoweredOn"
        case .resetting:
            stateMessage += "Resetting"
        case .unauthorized:
            stateMessage += "Unauthorized"
        case .unsupported:
            stateMessage += "Unsupported"
        case .unknown:
            stateMessage += "Unknown"
        }
        NSLog(stateMessage)
        
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        guard let name = peripheral.name else{
            return
        }
        if oxiDevice != nil{
            return
        }
        if (currentPeripheral != nil || disposedUUID.contains(peripheral.identifier.uuidString)){
            return
        }
        
        
        if (name.contains("AULISA")){
            NSLog("didDiscoverPeripheral : \(name)" )

            currentPeripheral = peripheral
            currentPeripheral?.delegate = self
            central.connect(peripheral, options: [CBConnectPeripheralOptionNotifyOnDisconnectionKey:true])
            central.stopScan()

        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        NSLog("didDisconnectPeripheral : \(peripheral.name)" )
        print(error)
        if (peripheral == currentPeripheral){
            currentPeripheral = nil
            systemIDCharacteristic = nil
            central.scanForPeripherals(withServices: nil, options: nil)
        } else if (peripheral == oxiDevice?.pheripheral){
            if (oxiDevice!.isPowerOff()){
                
            } else {
                delegate?.didOxiDeviceDisconnected(manager: self, device: oxiDevice!)
            }
            oxiDevice = nil

        }
       
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        NSLog("didConnect : \(peripheral.name)")
        guard currentPeripheral != nil else{
            return
        }
        peripheral.discoverServices([CBUUID(string:AUBleManager.UUID_S_DeviceInformation)])
        
    }
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        NSLog("didFailToConnect : \(peripheral.name)")
    }
    
   
    
}

extension AUBleManager : CBPeripheralDelegate {
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        guard currentPeripheral == peripheral else {
            return;
        }
        
        guard let services = peripheral.services else {
            NSLog("Find no services")
            return
        }
        
        for s in services {
            let uuidStr = s.uuid.uuidString
            NSLog("S : \(uuidStr)")
            if uuidStr == AUBleManager.UUID_S_DeviceInformation{
                NSLog("device information")
                peripheral.discoverCharacteristics([CBUUID(string:AUBleManager.UUID_C_SystemID)], for: s)
            }
        }
        
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        guard let characteristics = service.characteristics else{
            NSLog("Find no characteristics")
            return
        }
        for c in characteristics {
            
            let uuidStr = c.uuid.uuidString
            switch uuidStr{
            case AUBleManager.UUID_C_SystemID :
                //Need to check mac addrress
                NSLog("C : \(uuidStr)")
                if systemIDCharacteristic == nil {
                    systemIDCharacteristic = c
                    peripheral.readValue(for: c)
                }
            default:
                NSLog("C : \(c.uuid.uuidString)")
            }
            
        }
        
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        guard currentPeripheral != nil else {
            return
        }
        guard systemIDCharacteristic == characteristic else{
            return
        }
        guard characteristic.uuid.uuidString == AUBleManager.UUID_C_SystemID else {
            return;
        }
        
        guard let data = characteristic.value else{
            return
        }
        
        var rawData = [CUnsignedChar](repeating: 0, count: data.count)
        data.copyBytes(to: &rawData, count: data.count)
        
        let mac = bleRawDataToMacStr(raw: rawData)
        NSLog(mac)
        if macList.contains(mac){
            //TODO: AUDevice
            oxiDevice = AUOximeter(peripheral: currentPeripheral!, macAddress: mac)
            oxiDevice?.delegate = oxiDelegate
        
            scanTimer?.invalidate()
            currentPeripheral = nil;
            systemIDCharacteristic = nil
        } else {
            //Not Our Target Device
            disposedUUID.append(currentPeripheral!.identifier.uuidString)
            centralManager.cancelPeripheralConnection(currentPeripheral!)
            systemIDCharacteristic = nil
        }
        
    }
    
    func bleRawDataToMacStr(raw : [CUnsignedChar]) -> String{
        
        var mac = ""
        guard raw.count == 8 else{
            return mac
        }
        for i in (0..<8).reversed(){
            if i == 3 || i == 4 {
                continue
            }
            mac += String(format:"%02X", raw[i])
        }
        
        return mac
    }
    
}

public protocol AUBleManagerDelegate {
    
    func didBLEUpdateState(manager : AUBleManager ,  state : CBManagerState)
    func didOxiDeviceDisconnected(manager : AUBleManager, device : AUOximeter)
    func isTimeOut(manager : AUBleManager)
}

