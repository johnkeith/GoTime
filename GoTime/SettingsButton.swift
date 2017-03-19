//
//  SettingsButton.swift
//  GoTime
//
//  Created by John Keith on 3/18/17.
//  Copyright © 2017 John Keith. All rights reserved.
//

import UIKit

protocol SettingsButtonDelegate: class {
    func onSettingsTap(sender: SettingsButton)
}

class SettingsButton: UIButton {
    var delegate: SettingsButtonDelegate!
    
    init() {
        let defaultFrame = CGRect(x: 0, y: 0, width: 100, height: 100)
        let buttonImage = UIImage(named: "ic_more_horiz")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)

        super.init(frame: defaultFrame)
        
        self.tintColor = Constants.colorPalette["black"]
        self.setImage(buttonImage, for: UIControlState.normal)
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignment.right
        
        addTarget(self, action:#selector(onSettingsTap), for: .touchUpInside)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    func onSettingsTap(sender: SettingsButton) {
        delegate.onSettingsTap(sender: sender)
    }
    
    func hide() {
        isHidden = true
    }
    
    func show() {
        isHidden = false
    }
}
