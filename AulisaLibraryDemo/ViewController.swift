//
//  ViewController.swift
//  AulisaLibraryDemo
//
//  Created by Li Yun Jung on 2020/9/9.
//  Copyright © 2020 Aulisa. All rights reserved.
//

import UIKit
import CoreBluetooth
import AUOximeter


class ViewController: UIViewController {
    
    @IBOutlet weak var titleView : TitleBar!
    @IBOutlet weak var spo2View: SpO2View!
    @IBOutlet weak var bpmView: BPMView!
    @IBOutlet weak var paView: PAView!
    @IBOutlet weak var sensorView: SensorView!
    
    let bleManager = AUBleManager.shared
    
    var connectingDialog : UIAlertController?
    var calculatingDialog : UIAlertController?
    
    var currentAlert : UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //isTimeOut(manager: bleManager)
        self.bleManager.delegate = self
        self.bleManager.oxiDelegate = self
        self.titleView.setLeftButton(UIImage(named: "list.png"), target: self, action: #selector(settingButtonClick))
    }
    
    
    @objc func settingButtonClick(){
        showSettingAlertController()
    }
    
    
    func showSettingAlertController(){
        
        //dismissCurrentAlertController()
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        
        let pairingAction = UIAlertAction(title: "Pairing".localized, style: .default) { (UIAlertAction) in
            self.showPairingAlertController()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel) { (UIAlertAction) in
        }
        
        alertController.addAction(pairingAction)
        alertController.addAction(cancelAction)
        
        currentAlert = alertController
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showPairingAlertController(){
        
        //dismissCurrentAlertController()
        
        let alertController = UIAlertController(title: "Serial Number of Aulisa Sensor Module", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.text = "00028A"
            textField.delegate = self
        }
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (alertAction) in
            
            guard let textFields = alertController.textFields, textFields.count > 0 else {
                return;
            }
            guard let text = textFields[0].text else {
                return;
            }
            NSLog(text)
            
            self.bleManager.startScan(macList: ["00025B"+text])
            self.showConnectingAlertController()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alertAction) in
            
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        currentAlert = alertController
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showConnectingAlertController(){
        
        dismissCurrentAlertController()
        
        let alertController = UIAlertController(title: "Connecting...", message:"\n\n", preferredStyle: .alert)
        
        let indicator = UIActivityIndicatorView(frame: alertController.view.bounds)
        indicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        //add the activity indicator as a subview of the alert controller's view
        alertController.view.addSubview(indicator)
        indicator.isUserInteractionEnabled = false // required otherwise if there buttons in the UIAlertController you will not be able to press them
        indicator.startAnimating()
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.bleManager.stopScan();
        }
        
        alertController.addAction(cancelAction)
        self.connectingDialog = alertController
        self.currentAlert = alertController
        self.present(alertController,animated: true,completion: nil)
    }
    
    func showCalculatingAlertController(){
        
        if (currentAlert == calculatingDialog){
            return
        }
        dismissCurrentAlertController()
        
        let alertController = UIAlertController(title: "Calculating...", message:"\n\n", preferredStyle: .alert)
        
        let indicator = UIActivityIndicatorView(frame: alertController.view.bounds)
        indicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        //add the activity indicator as a subview of the alert controller's view
        alertController.view.addSubview(indicator)
        indicator.isUserInteractionEnabled = false // required otherwise if there buttons in the UIAlertController you will not be able to press them
        indicator.startAnimating()
        
        self.calculatingDialog = alertController
        self.currentAlert = alertController
        
        
        self.present(alertController,animated: true,completion: nil)
        
    }
    
    func showTimeOutAlertController(){
        dismissCurrentAlertController()
        
        let alertController = UIAlertController(title: "Fail to connect sensor", message: "Please check your sensor is on", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.currentAlert = alertController
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func dismissCurrentAlertController(){
        if let currentAlert = self.currentAlert {
            currentAlert.dismiss(animated: true, completion: nil)
            self.currentAlert = nil
        }
        
    }
    func dismissCalculatingAlertController(){
        
        self.calculatingDialog?.dismiss(animated: true, completion: nil)
        self.currentAlert = nil
    }
}


extension ViewController : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let textFieldText = textField.text,
              let rangeOfTextToReplace = Range(range, in: textFieldText) else {
            return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        if count > 6 {
            return false
        }
        
        let set = NSCharacterSet(charactersIn: "ABCDEFabcdef0123456789").inverted
        return string.rangeOfCharacter(from: set) == nil
    }
    
}

extension ViewController : AUBleManagerDelegate {
    
    
    func didBLEUpdateState(manager: AUBleManager, state: CBManagerState) {
        //TODO: Alert Dialog
        switch state {
        case .poweredOff:
            //TODO: Show Open BLE Alert
            break;
        case .poweredOn:
            break
        default:
            break
        }
    }
    
    func didOxiDeviceDisconnected(manager: AUBleManager, device: AUOximeter) {
        //Disconnect Oximeter Abnormally
        NSLog("didOxiDeviceDisconnected")
        self.titleView.setSerialNumber(nil)
        self.spo2View.clear()
        self.bpmView.clear()
        self.paView.clear()
        self.sensorView.disconnect()
    }
    
    func isTimeOut(manager: AUBleManager) {
        showTimeOutAlertController()
    }
    
}

extension ViewController : AUOximeterDataDelegate {
    
    func notifyRawData(device: AUOximeter, rawData: AUOximeterRawData) {
        
    }
    
    func didSMConnect(device: AUOximeter) {
        
        print("didSMConnect")
        guard let macAddress = device.macAddress else {
            didOxiDeviceDisconnected(manager: bleManager, device: device)
            return;
        }
        self.titleView.setSerialNumber(macAddress)
        self.sensorView.setType(AUDevice.macAddressToSMType(macAddress: macAddress))
        self.sensorView.didConnect()
        self.showCalculatingAlertController()
        device.setAlarmLimit(alarmLimit: AUOximeterAlarmLimit.defaultAlarm(sensorType:
                                                                            device.sensorType))
        
        //TODO: Sensor Type
    }
    
    func didSMPowerOff(device: AUOximeter) {
        //User Click Power Off
        NSLog("didSMPowerOff")
        
        self.titleView.setSerialNumber(nil)
        self.spo2View.clear()
        self.bpmView.clear()
        self.paView.clear()
        self.sensorView.clear()
    }
    
    func notifyInfo(device: AUOximeter, info: AUOximeterData) {
        
        NSLog("\(info.SpO2),\(info.PR),\(info.PA)")
        if (info.isPowerOff()){
            didSMPowerOff(device: device)
            return
        }
        
        if (!info.isNoneValueData() || info.isFingerOff() || info.isSensorOff()){
            dismissCalculatingAlertController()
        } else {
            showCalculatingAlertController()
        }
        
        self.spo2View.setSPO2(info)
        self.bpmView.setBPM(info)
        self.paView.setPA(info)
        self.sensorView.setStatus(data: info)
        
        //TODO: Sensor View
    }
    
    func notifyAlarmLimit(device: AUOximeter, alarmLimit: AUOximeterAlarmLimit) {
        
        self.spo2View.setAlarmLimit(alarmLimit)
        self.bpmView.setAlarmLimit(alarmLimit)
    }
    
}
