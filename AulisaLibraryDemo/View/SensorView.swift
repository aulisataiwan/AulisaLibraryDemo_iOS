//
//  StatusView.swift
//  GA
//
//  Created by Li Yun Jung on 2017/8/2.
//  Copyright © 2017年 Li Yun Jung. All rights reserved.
//

import UIKit
import AUOximeter

@IBDesignable class SensorView: UIView {
    
    
    @IBOutlet weak var ga1000View: UIView!
    @IBOutlet weak var fingerImageView: UIImageView!
    @IBOutlet weak var bluetooth1000ImageView: UIImageView!
    @IBOutlet weak var sensorImageView: UIImageView!
    @IBOutlet weak var battery1000ImageView: UIImageView!
    
    @IBOutlet weak var ga1001View: UIView!
    @IBOutlet weak var footImageView: UIImageView!
    @IBOutlet weak var bluetooth1001ImageView: UIImageView!
    @IBOutlet weak var battery1001ImageView: UIImageView!
    
    var animationTimer : Timer?
    
    private var imageAlpha = 0.2 {
        didSet {
            if oldValue != imageAlpha{
                
                DispatchQueue.main.async {
                    
                    
                    for image in self.getImageViewsInView(){
                        image.alpha = CGFloat(self.imageAlpha)
                    }
                }
                
                
            }
        }
    }
    
    private var sensorType : AUSensorType = .Oxi1000 {
        didSet {
            if oldValue != sensorType {
                if sensorType == .Oxi1000 {
                    ga1000View.isHidden = false
                    ga1001View.isHidden = true
                } else if sensorType == .Oxi1001 {
                    ga1000View.isHidden = true
                    ga1001View.isHidden = false
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }
    
    func initSubviews() {
        
        // standard initialization logic
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let contentView = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        contentView.frame = bounds
        contentView.autoresizingMask = [
            UIView.AutoresizingMask.flexibleWidth,
            UIView.AutoresizingMask.flexibleHeight
        ]
        
        self.layer.cornerRadius = 12.0
        self.layer.masksToBounds = true
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.borderWidth = 6
        
        addSubview(contentView)
        
        for imageView in getImageViewsInView() {
            imageView.image = imageView.image?.imageWithInsets(insetDimen: 5.0).withRenderingMode(.alwaysTemplate)
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 12.0
        }
        clear()
    }
    
    func clear(){
        
        self.imageAlpha = 0.2
        DispatchQueue.main.async {
            self.setFingerStatus(true, motionCount : 0)
            self.setBluetoothStatus(.None)
            self.setSensorStatus(true)
            self.setBatteryStatus(.Full)
        }
    }
    
    func disconnect(){
        
        self.imageAlpha = 1.0
        DispatchQueue.main.async {
            self.setFingerStatus(true, motionCount: 0)
            self.setBluetoothStatus(.Disconnected)
            self.setSensorStatus(true)
            self.setBatteryStatus(.Full)
        }
        
    }
    
    func didConnect(){
        self.imageAlpha = 1.0
        DispatchQueue.main.async {
            self.setFingerStatus(true, motionCount: 0)
            self.setBluetoothStatus(.Connected)
            self.setSensorStatus(true)
            self.setBatteryStatus(.Full)
        }
    }
    
    func setType(_ sensorType : AUSensorType){
        self.sensorType = sensorType
    }
    
    func setStatus(data : AUOximeterData){
        
        self.imageAlpha = data.isPowerOff() ? 0.2 : 1.0
        self.setFingerStatus(!data.isFingerOff(), motionCount: data.motionCount)
        self.setSensorStatus(!data.isSensorOff())
        self.setBatteryStatus(data.batteryStatus)
        self.setBluetoothStatus(data.isPowerOff() ? .Disconnected : .Connected)
    }
    
    private func setFingerStatus(_ status : Bool, motionCount : Int){
        
        DispatchQueue.main.async{
            
            if (!status){
                
                self.fingerImageView.tintColor = UIColor.black
                self.fingerImageView.backgroundColor = UIColor(0xffff00,alpha : 1.0)
                self.footImageView.stopAnimating()
                self.footImageView.animationImages = nil
                self.footImageView.image = UIImage(named:"aulisa_sensor_status_foot_on")!.withRenderingMode(.alwaysTemplate)
                self.footImageView.tintColor = UIColor.black
                self.footImageView.backgroundColor = UIColor(0xffff00,alpha : 1.0)
                
            } else {
                
                if (motionCount >= 8) {
                    
                    self.footImageView.tintColor = UIColor.white
                    self.footImageView.backgroundColor = UIColor.clear
                    self.footImageView.alpha = CGFloat(self.imageAlpha)
                    self.footImageView.image = nil
                    self.footImageView.animationImages =
                        [UIImage(named: "aulisa_sensor_status_foot_motion_1")!,
                         UIImage(named: "aulisa_sensor_status_foot_motion_2")!]
                    
                    self.footImageView.animationDuration = 1.0
                    self.footImageView.startAnimating()
                    
                } else {
                    
                    self.footImageView.stopAnimating()
                    self.footImageView.animationImages = nil
                    self.footImageView.image = UIImage(named:"aulisa_sensor_status_foot_on")!.withRenderingMode(.alwaysTemplate)
                    self.footImageView.tintColor = UIColor.white
                    self.footImageView.backgroundColor = UIColor.clear
                    self.footImageView.alpha = CGFloat(self.imageAlpha)
                }
                
                self.fingerImageView.tintColor = UIColor.white
                self.fingerImageView.backgroundColor = UIColor.clear
                self.fingerImageView.alpha = CGFloat(self.imageAlpha)
            }
            
            
            
        }
        
    }
    
    private func setBluetoothStatus(_ status : BLEStatus){
        
        var imageName = ""
        
        switch status {
        case .None:
            imageName = "aulisa_sensor_status_bluetooth_white"
        case .Connecting: fallthrough
        case .Connected:
            imageName = "aulisa_sensor_status_bluetooth_blue"
        case .Disconnected:
            imageName = "aulisa_sensor_status_bluetooth_white"
        default :
            break
        }
        if let image = UIImage(named: imageName){
            DispatchQueue.main.async {
                self.bluetooth1000ImageView.image = image.imageWithInsets(insetDimen: 5.0).withRenderingMode(.alwaysTemplate)
                self.bluetooth1000ImageView.layer.removeAllAnimations()
                self.bluetooth1001ImageView.image = image.imageWithInsets(insetDimen: 5.0).withRenderingMode(.alwaysTemplate)
                self.bluetooth1001ImageView.layer.removeAllAnimations()
                //TODO:
                if (status == .Disconnected){
                    self.bluetooth1000ImageView.tintColor = UIColor.black
                    self.bluetooth1001ImageView.tintColor = UIColor.black
                }else if (status == .Connected){
                    self.bluetooth1000ImageView.tintColor = UIColor(0x0061a8,alpha : 1.0)
                    self.bluetooth1001ImageView.tintColor = UIColor(0x0061a8,alpha : 1.0)
                }else {
                    self.bluetooth1000ImageView.tintColor = UIColor.white
                    self.bluetooth1001ImageView.tintColor = UIColor.white
                }
                self.bluetooth1000ImageView.backgroundColor = status != .Disconnected ? UIColor.clear :UIColor(0xffff00,alpha : 1.0)
                self.bluetooth1001ImageView.backgroundColor = status != .Disconnected ? UIColor.clear :UIColor(0xffff00,alpha : 1.0)
            }
        }
        
        DispatchQueue.main.async {
            
            if status == .Connecting{
                self.bluetooth1000ImageView.alpha = 1.0
                self.bluetooth1001ImageView.alpha = 1.0
                UIView.animate(withDuration: 1.0, delay: 0, options: [UIView.AnimationOptions.autoreverse,UIView.AnimationOptions.repeat], animations: {
                    self.bluetooth1000ImageView.alpha = 0.0
                    self.bluetooth1001ImageView.alpha = 0.0
                }, completion: nil)
                
                
                
                
            } else {
                
                self.bluetooth1000ImageView.alpha = CGFloat(self.imageAlpha)
                self.bluetooth1001ImageView.alpha = CGFloat(self.imageAlpha)
                self.animationTimer?.invalidate()
            }
        }
    }
    
    
    
    private func setSensorStatus(_ status : Bool){
        
        DispatchQueue.main.async {
            self.sensorImageView?.tintColor = status ? UIColor.white : UIColor.black
            self.sensorImageView?.backgroundColor = status ?  UIColor.clear :UIColor(0xffff00,alpha : 1.0)
            self.sensorImageView?.alpha = CGFloat(self.imageAlpha)
        }
    }
    
    private func setBatteryStatus(_ status : BatteryStatus){
        
        DispatchQueue.main.async {
            var imageName = ""
            var tintColor : UIColor!
            var backgroundColor : UIColor!
            switch status{
            case .Full:
                imageName = "aulisa_battery_full"
                tintColor = .white
                backgroundColor = .clear
            case .High:
                imageName = "aulisa_battery_medium_white"
                tintColor = .white
                backgroundColor = .clear
            case .Low:
                imageName = "aulisa_battery_low_yellow"
                tintColor = .black
                backgroundColor = UIColor(0xffff00,alpha : 1.0)
            case .Empty:
                imageName = "aulisa_battery_critical_yellow"
                tintColor = .black
                backgroundColor = UIColor(0xffff00,alpha : 1.0)
            }
            if let image = UIImage(named: imageName){
                self.battery1000ImageView.image = image.imageWithInsets(insetDimen: 5.0).withRenderingMode(.alwaysTemplate)
                self.battery1001ImageView.image = image.imageWithInsets(insetDimen: 5.0).withRenderingMode(.alwaysTemplate)
            }
            self.battery1000ImageView.tintColor = tintColor
            self.battery1000ImageView.backgroundColor = backgroundColor
            self.battery1000ImageView.alpha =  CGFloat(self.imageAlpha)
            self.battery1001ImageView.tintColor = tintColor
            self.battery1001ImageView.backgroundColor = backgroundColor
            self.battery1001ImageView.alpha =  CGFloat(self.imageAlpha)
            
        }
    }
    
    
    
    func onTimerEvent(timer: Timer) {
        DispatchQueue.main.async {
            self.bluetooth1000ImageView.isHidden = !self.bluetooth1000ImageView.isHidden
            self.bluetooth1001ImageView.isHidden = !self.bluetooth1000ImageView.isHidden
        }
    }
    
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}

