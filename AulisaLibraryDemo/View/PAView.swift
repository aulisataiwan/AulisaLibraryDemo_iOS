//
//  PAView.swift
//  GA
//
//  Created by Li Yun Jung on 2017/8/2.
//  Copyright © 2017年 Li Yun Jung. All rights reserved.
//

import UIKit
import AUOximeter

@IBDesignable class PAView: UIView {
    
    @IBOutlet weak var PALabel: UILabel!
    @IBOutlet weak var PABarImageView : UIImageView!
    private var hasAnimation : Bool = false
    private var timer : Timer?
    private var maxValue : Double = 0.0
    private var pa : Double = 0.0
    private var bpm : Int = 0
    private var currentValue : Double = 0.0
    private var progressValue : Double = 0.0
    private var progressTime : Double = 0.0
    private var progressDirection : Bool = true /// true : ascend
    
    private var sensorType : AUSensorType = .Oxi1000

    
    //    let verticalProgressView: VerticalProgressView = {
    //        let progressView = VerticalProgressView()
    //        progressView.translatesAutoresizingMaskIntoConstraints = false
    //        return progressView
    //    }()
    
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
        
        self.layer.cornerRadius = 15.0
        self.layer.masksToBounds = true
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.borderWidth = 6
        
        addSubview(contentView)
        
        for label in self.getLabelsInView(){
            label.textColor = UIColor.paColor
        }
        
        maskPABarImage(showPercentage: 0.0)
    }
    
    
    public func maskPABarImage(showPercentage : Double){
        
        let mask = CALayer()
        mask.backgroundColor = UIColor.black.cgColor
        let height = PABarImageView.frame.height
        mask.frame = CGRect(x: 0, y: height * CGFloat(1 - showPercentage), width: PABarImageView.frame.width, height: height * CGFloat(showPercentage))
        PABarImageView.layer.mask = mask
        PABarImageView.layer.masksToBounds = true
        PABarImageView.image  = PABarImageView.image?.withRenderingMode(.alwaysTemplate)
        currentValue = showPercentage
    }
    func setPA(_ data : AUOximeterData){
        
        let paValue = data.PA
        let bpm  = data.PR
        
        DispatchQueue.main.async {
            
            if paValue > 0 {
                self.PALabel.text = String.init(format: "%.2f", paValue)
            }else{
                self.clear()
                return
            }
            
            self.pa = paValue
            self.bpm = bpm
            if (!self.hasAnimation){
                self.hasAnimation = true
                self.setBarValue(pa: paValue, bpm: bpm)
                self.timer = Timer.scheduledTimer(timeInterval: self.progressTime, target: self, selector: #selector(self.paBarTimer), userInfo: nil, repeats: true)
            }
            
            
        }
    }
    
    func clear(){
        DispatchQueue.main.async {
            self.PALabel.text = "--.--"
            self.PALabel.layer.removeAllAnimations()
            self.hasAnimation = false
            self.timer?.invalidate()
            self.timer = nil
            self.maskPABarImage(showPercentage: 0.0)
        }
    }
    
    func setType(_ type : AUSensorType){
        sensorType = type
    }
    
    private func setBarValue(pa : Double,bpm : Int) {
        
        self.PABarImageView.tintColor = UIColor.paColor
        
        if (pa <= 0){
            progressTime = 0.05
            maxValue = 1.0
            return
        }
        progressTime = 3.0 / Double(bpm)
       if (sensorType == .Oxi1001){
                 if (pa < 0.1){
                     maxValue = 0.175
                     self.PABarImageView.tintColor = UIColor(0xffff00,alpha : 1.0)
                 } else if (pa < 0.3) {
                     maxValue = 0.28
                 } else if (pa < 0.5) {
                     maxValue = 0.425
                 } else if (pa < 0.7) {
                     maxValue = 0.56
                 } else if (pa < 1) {
                     maxValue = 0.69
                 } else if (pa < 2) {
                     maxValue = 0.82
                 } else {
                     maxValue = 1.0
                 }
             } else {
                 if (pa < 0.5){
                     maxValue = 0.175
                     self.PABarImageView.tintColor = UIColor(0xffff00,alpha : 1.0)
                 } else if (pa < 0.75) {
                     maxValue = 0.28
                 } else if (pa < 1) {
                     maxValue = 0.425
                 } else if (pa < 2) {
                     maxValue = 0.56
                 } else if (pa < 3) {
                     maxValue = 0.69
                 } else if (pa < 5) {
                     maxValue = 0.82
                 } else {
                     maxValue = 1.0
                 }
             }
    
        
    }
    
    
    @objc func paBarTimer(){
        DispatchQueue.main.async {
            
            if (!self.hasAnimation){
                return
            }
            
            if (self.currentValue >= self.maxValue){
                self.progressDirection = false;
            }
            var nextProgress : Double
            if self.progressDirection {
                nextProgress = self.currentValue + self.maxValue / 10.0
            }else {
                nextProgress = self.currentValue - self.maxValue / 10.0
            }
            self.maskPABarImage(showPercentage: nextProgress)
            if (nextProgress <= 0.0){
                self.progressDirection = true
                self.timer?.invalidate()
                self.setBarValue(pa: self.pa, bpm: self.bpm)
                self.timer = Timer.scheduledTimer(timeInterval: self.progressTime, target: self, selector: #selector(self.paBarTimer), userInfo: nil, repeats: true)
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
