//
//  LapTableController.swift
//  GoTime
//
//  Created by John Keith on 5/25/17.
//  Copyright © 2017 John Keith. All rights reserved.
//

import UIKit

class LapTableController: UIViewController {
    let lapTable = LapTimeTable()
    
    init(lapTimes: [Double]) {
        lapTable.setLapData(lapData: lapTimes)
        lapTable.reloadData()
        
        super.init(nibName: nil, bundle: nil)
        
        lapTable.setRowHeightBySuperview(_superview: self.view)
        
        self.view.addSubview(lapTable)
        self.view.backgroundColor = Constants.colorPalette["_black"]
        
        configLapTable()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.isTranslucent = true
//        self.navigationController?.navigationBar.barTintColor = Constants.colorPalette["_black"]
        self.navigationController?.navigationBar.backgroundColor = Constants.colorPalette["_black"]
        self.navigationController?.view.backgroundColor = Constants.colorPalette["_black"]
        self.navigationController?.navigationBar.tintColor = Constants.colorPalette["_white"]
        self.navigationItem.title = "Lap Times"
        self.navigationController?.navigationBar.backItem?.title = ""
        
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    func configLapTable() {
        lapTable.isHidden = false
        lapTable.snp.makeConstraints({ make in
            make.width.equalTo(lapTable.superview!)
            make.top.equalTo(lapTable.superview!)
            make.bottom.equalTo(lapTable.superview!)
        })
    }
}