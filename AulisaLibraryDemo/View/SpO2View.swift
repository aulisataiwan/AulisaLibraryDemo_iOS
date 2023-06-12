//
//  SpO2View.swift
//  GA
//
//  Created by Li Yun Jung on 2017/8/2.
//  Copyright © 2017年 Li Yun Jung. All rights reserved.
//

import UIKit
import AUOximeter


@IBDesignable class SpO2View: UIView {
    
    @IBOutlet weak var SpO2Label : UILabel!
    @IBOutlet weak var SpO2AlarmLabel : UILabel!
    @IBOutlet weak var alarmMaxLabel : UILabel!
    @IBOutlet weak var alarmMinLabel : UILabel!
    @IBOutlet weak var alarmMuteIamge : UIImageView!
    private var hasAnimation : Bool = false
    
    private var max : Int? {
        didSet{
            self.alarmMaxLabel.text = max != nil ? "\(max!)" : ""
        }
    }
    private var min : Int? {
        didSet{
            self.alarmMinLabel.text = min != nil ? "\(min!)" : ""
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
        let contentView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        contentView.frame = bounds
        contentView.autoresizingMask = [
            UIView.AutoresizingMask.flexibleWidth,
            UIView.AutoresizingMask.flexibleHeight
        ]
        
        //self.layer.cornerRadius = 15.0
        //self.layer.masksToBounds = true
        //self.layer.borderColor = UIColor.clear.cgColor
        //self.layer.borderWidth = 6
        
        alarmMuteIamge.image = alarmMuteIamge.image?.withRenderingMode(.alwaysTemplate)
        alarmMuteIamge.tintColor = UIColor.white
        
        addSubview(contentView)
        clear()
    }
    
    func setSPO2(_ data : AUOximeterData){
        
        
        let SPO2 : Int = data.SpO2
        let alarmStatus = data.isSpo2High() || data.isSpo2Low()
        DispatchQueue.main.async{
            
            self.alarmMinLabel.isHidden = false
            self.alarmMaxLabel.isHidden = false
            self.setAnimation(hasAlarm: alarmStatus)
            

            if SPO2 > 0 {
                if (alarmStatus){
                    self.SpO2AlarmLabel.text = "\(SPO2)"
                    self.SpO2Label.text = ""
                }else{
                    self.SpO2Label.text =  "\(SPO2)"
                    self.SpO2AlarmLabel.text = ""
                }
            }else{
                self.SpO2Label.text = "---"
                self.SpO2AlarmLabel.text = ""
                self.setAnimation(hasAlarm: false)
            }
        }
    }
    
    func setAlarmLimit(_ alarmLimit : AUOximeterAlarmLimit){
        
        DispatchQueue.main.async {
            self.min = alarmLimit.spo2Low
            self.max = alarmLimit.spo2High
            self.setAlarmMute(isMute: alarmLimit.isAlarmMute())
        }
    }
    
    
    func clear(){
        
        DispatchQueue.main.async {
            
            self.SpO2Label.text = "---"
            self.SpO2Label.alpha = 1.0
            self.SpO2Label.layer.removeAllAnimations()
            self.SpO2AlarmLabel.text = ""
            self.alarmMinLabel.isHidden = true
            self.alarmMaxLabel.isHidden = true
            self.subviews[0].layer.removeAllAnimations()
            self.subviews[0].layer.backgroundColor = UIColor.black.cgColor
            self.setAnimation(hasAlarm: false)
            self.hasAnimation = false
            self.setAlarmMute(isMute: false)
        }
    }
    
    private func setAnimation(hasAlarm : Bool){
        
        DispatchQueue.main.async {
            
            if (!hasAlarm){
                self.subviews[0].layer.backgroundColor = UIColor.black.cgColor
    
                for label in self.getLabelsInView(){
                    label.textColor = UIColor.white
                }
            }else{
                
                self.subviews[0].layer.backgroundColor = UIColor.red.cgColor
                for label in self.getLabelsInView(){
                    label.textColor = UIColor.black
                }
            }
        }
    }
    
    private func setAlarmMute(isMute : Bool){
        DispatchQueue.main.async{
            self.alarmMuteIamge.isHidden = isMute ? false : true
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
