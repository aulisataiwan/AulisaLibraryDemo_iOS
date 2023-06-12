//
//  TitalBar.swift
//  GA1000E
//
//  Created by Li Yun Jung on 2018/10/26.
//  Copyright © 2018年 Aulisa. All rights reserved.
//

import UIKit

@IBDesignable class TitleBar: UIView {
    
    @IBOutlet weak var titleImage : UIImageView!
    @IBOutlet weak var titleLabel : UILabel!
    @IBOutlet weak var patientNameLabel : UILabel!
    @IBOutlet weak var serialNumberLabel: UILabel!
    @IBOutlet weak var serialNumberImage : UIImageView!
    @IBOutlet weak var leftButton : UIButton!
    @IBOutlet weak var rightButton : UIButton!

    
    let bottomLayer = CALayer()
    
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
        
        addSubview(contentView)
        
       
        setTitle(nil)
        setSerialNumber(nil)
        setPatientName(nil)
    }
    
    override func layoutSubviews() {
    
        bottomLayer.backgroundColor = UIColor(0xffffff,alpha : 0.2).cgColor
        bottomLayer.frame = CGRect(x:0, y:self.frame.size.height - 1.0, width:self.frame.size.width, height:1.0)
        bottomLayer.removeFromSuperlayer()
        self.layer.addSublayer(bottomLayer)
    }
    
   
    override func didMoveToWindow() {
        
       
        //        serialNumberImage.layer.borderWidth = 1
        //        serialNumberImage.layer.borderColor = UIColor.white.cgColor
        //
    }
    
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    public func setTitle(_ title : String?){
        DispatchQueue.main.async{
            if let title = title {
                self.titleImage.isHidden = true
                self.titleLabel.text = title
                self.titleLabel.isHidden = false
            } else {
                self.titleImage.isHidden = false
                self.titleLabel.isHidden = true
            }
        }
    }
    
    public func setSerialNumber(_ serialNumber : String?){
        
        DispatchQueue.main.async{
            if let str = serialNumber {
                let length = str.count
                let indexStartOfText = str.index(str.startIndex, offsetBy: length-6)
                let sn = length <= 6 ? str : String(str[indexStartOfText...])
                self.serialNumberLabel.text = sn
                self.serialNumberLabel.isHidden = false
                self.serialNumberImage.isHidden = false
                self.serialNumberImage.image = UIImage(named: "serial_number.png")!.withRenderingMode(.alwaysTemplate)
                self.serialNumberImage.tintColor = UIColor.white
            }else{
                self.serialNumberLabel.isHidden = true
                self.serialNumberImage.isHidden = true
                //self.alarmMuteIamge.isHidden = true
            }
        }
    }
    
    public func setPatientName(_ name : String?){
        
        DispatchQueue.main.async{
            if let name = name {
                self.patientNameLabel.text = name
                self.patientNameLabel.isHidden = false
                self.patientNameLabel.textAlignment = .right
                //self.patientNameLabel.sizeToFit()
            }else{
                self.patientNameLabel.isHidden = true
            }
        }
    }
    
    public func setLeftButton(_ image : UIImage? ,target : Any?, action : Selector?){
          
          DispatchQueue.main.async{
              
              self.leftButton.removeTarget(nil, action: nil, for: .allEvents)
              guard let image = image else{
                  self.leftButton.isHidden = true
                  self.leftButton.setImage(nil, for: .normal)
                  self.leftButton.isEnabled = false;
                  
                  return
              }
              
              if (action != nil){
                  self.leftButton.isHidden = false
                  self.leftButton.setImage(image, for: .normal)
                  self.leftButton.isEnabled = true;
                  self.leftButton.addTarget(target, action: action!, for: .touchUpInside)
              }
          }
      }
      
      public func setRightButton(_ image : UIImage? ,target : Any?, action : Selector?){
          
          DispatchQueue.main.async{
              
              self.rightButton.removeTarget(nil, action: nil, for: .allEvents)
              guard let image = image else{
                  self.rightButton.isHidden = true
                  self.rightButton.setImage(nil, for: .normal)
                  self.rightButton.isEnabled = false;
                  return
              }
              
              if (action != nil){
                  self.rightButton.isHidden = false
                  self.rightButton.setImage(image, for: .normal)
                  self.rightButton.isEnabled = true;
                  self.rightButton.addTarget(target, action: action!, for: .touchUpInside)
              }
          }
      }

      
    
}
