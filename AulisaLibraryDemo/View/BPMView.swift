//
//  BPMView.swift
//  GA
//
//  Created by Li Yun Jung on 2017/8/2.
//  Copyright © 2017年 Li Yun Jung. All rights reserved.
//

import UIKit
import AUOximeter

@IBDesignable class BPMView: UIView {
    
    @IBOutlet weak var BPMLabel: UILabel!
    @IBOutlet weak var BPMAlarmLabel : UILabel!
    @IBOutlet weak var alarmMinLabel: UILabel!
    @IBOutlet weak var alarmMaxLabel: UILabel!
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
    
    private func initSubviews() {
        
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
        
        addSubview(contentView)
        
        for label in self.getLabelsInView(){
            label.textColor = UIColor.bpmColor
        }
        clear()
    }
    
    func setBPM(_ data : AUOximeterData){
        
        let bpm : Int  = data.PR
        let alarmStatus : Bool = data.isPrHigh() || data.isPrLow()
        DispatchQueue.main.async{
            
            self.alarmMinLabel.isHidden = false
            self.alarmMaxLabel.isHidden = false
           
            self.setAnimation(hasAlarm: alarmStatus)
                
            if bpm > 0 {
                if (alarmStatus){
                    self.BPMAlarmLabel.text = "\(bpm)"
                    self.BPMLabel.text = ""
                }else{
                    self.BPMLabel.text = "\(bpm)"
                    self.BPMAlarmLabel.text = ""
                }
            }else{
                self.BPMLabel.text = "---"
                self.BPMAlarmLabel.text = ""
                self.setAnimation(hasAlarm: false)
            }
        }
    }
    
    func clear(){
        
        DispatchQueue.main.async {
            
            self.BPMLabel.text = "---"
            self.BPMLabel.alpha = 1.0
            self.BPMLabel.layer.removeAllAnimations()
            self.BPMAlarmLabel.text = ""
            self.alarmMinLabel.isHidden = true
            self.alarmMaxLabel.isHidden = true
            self.subviews[0].layer.removeAllAnimations()
            self.subviews[0].layer.backgroundColor = UIColor.black.cgColor
            self.hasAnimation = false
            self.setAnimation(hasAlarm: false)
        }
    }
    
    //isSet : true alarmLimit ,
    func setAlarmLimit(_ alarmLimit : AUOximeterAlarmLimit){
        
        DispatchQueue.main.async {
            self.min = alarmLimit.prLow
            self.max = alarmLimit.prHigh
        }
    }
    
    private func setAnimation(hasAlarm : Bool){
        
       
        DispatchQueue.main.async {
            
            if (!hasAlarm){
                self.subviews[0].layer.backgroundColor = UIColor.black.cgColor
                for label in self.getLabelsInView(){
                    label.textColor = UIColor.bpmColor
                }
            }else{
                self.subviews[0].layer.backgroundColor = UIColor.red.cgColor
                for label in self.getLabelsInView(){
                    label.textColor = UIColor.black
                }
            }
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
