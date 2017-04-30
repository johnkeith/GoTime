//
//  SettingsTable.swift
//  GoTime
//
//  Created by John Keith on 4/9/17.
//  Copyright © 2017 John Keith. All rights reserved.
//

import UIKit

// TODO: UNTESTED
class SettingsTable: UITableView {
    var settingsService: SettingsService
    
    init(settingsService: SettingsService = SettingsService()) {
        self.settingsService = settingsService
        
        super.init(frame: Constants.defaultFrame, style: .plain)
        
        self.dataSource = self
        self.delegate = self
        
        self.separatorStyle = .none
        self.showsVerticalScrollIndicator = false
        
        self.register(SettingsTableCell.self, forCellReuseIdentifier: "settingsTableCell")
        
        setColoration()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleNotificationOfDarkModeFlipped), name: Notification.Name(rawValue: Constants.notificationOfDarkModeToggle), object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SettingsTable: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsService.mapOfSettingsForTable.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.dequeueReusableCell(withIdentifier: "settingsTableCell") as! SettingsTableCell
        
        let displayName = settingsService.mapOfSettingsForTable[indexPath.row].displayName
        let userDefaultsKey = settingsService.mapOfSettingsForTable[indexPath.row].userDefaultsKey
        let shouldIndent = settingsService.mapOfSettingsForTable[indexPath.row].shouldIndent
        
        cell.userDefaultsKey = userDefaultsKey
        cell.shouldIndent = shouldIndent
        cell.setContent(displayName: displayName)
        cell.setToggleState()
        cell.addConstraints()
        
        return cell
    }
}

extension SettingsTable: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if settingsService.mapOfSettingsForTable[indexPath.row].userDefaultsKey == nil {
            return Constants.lapTimeTableCellHeight / 2
        } else {
            return Constants.lapTimeTableCellHeight
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat{
        return Constants.lapTimeTableCellHeight
    }
}

extension SettingsTable: RespondsToThemeChange {
    func handleNotificationOfDarkModeFlipped(notification: Notification) {
        let value = notification.userInfo?["value"] as! Bool
        
        setColoration(darkModeEnabled: value, animationDuration: 0.2)
    }
    
    func setColoration(darkModeEnabled: Bool = Constants.storedSettings.bool(forKey: SettingsService.useDarkModeKey), animationDuration: Double = 0.0) {
        UIView.animate(withDuration: animationDuration, animations: {
            if darkModeEnabled {
                self.backgroundColor = Constants.colorPalette["black"]
            } else {
                self.backgroundColor = Constants.colorPalette["white"]
            }
        })
    }
}
