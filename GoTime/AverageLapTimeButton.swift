//
//  AverageLapTimeButton.swift
//  GoTime
//
//  Created by John Keith on 3/26/17.
//  Copyright © 2017 John Keith. All rights reserved.
//

import UIKit

class AverageLapTimeButton: SettingsButton {
    init() {
        super.init()
        
        self.xMultiple = 1/5
        self.yMultiple = 2/5
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
