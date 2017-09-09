//
//  SettingsView.swift
//  GoTime
//
//  Created by John Keith on 9/3/17.
//  Copyright © 2017 John Keith. All rights reserved.
//

import UIKit

protocol SettingsViewDelegate: class {
    func onSave()
}

class SettingsView:UIView {
    let titleLabel = UILabel()
    let saveButton = UIView()
    let saveButtonLabel = UILabel()
    
    weak var delegate: SettingsViewDelegate?
    
    init(isHidden: Bool = true) {
        super.init(frame: Constants.defaultFrame)
        
        self.isHidden = isHidden
        
        backgroundColor = Constants.colorWhite
        clipsToBounds = true
        
        layer.cornerRadius = 16.0
        
        addtitleLabel()
        addSaveButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configConstraints() {
        let _height = superview!.frame.height - CGFloat(Constants.defaultMargin * 4)
        let _width = superview!.frame.width - CGFloat(Constants.defaultMargin * 2)
        
        snp.makeConstraints { make in
            make.center.equalTo(superview!)
            make.height.equalTo(_height)
            make.width.equalTo(_width)
        }
        
        layoutIfNeeded()
        
        configTitleLabelConstraints()
        configSaveButtonConstraints()
    }
    
    @objc func onSave() {
        delegate!.onSave()
    }
    
    private func configTitleLabelConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(titleLabel.superview!)
            make.height.equalTo(superview!.frame.height / Constants.tableRowHeightDivisor)
            make.width.equalTo(titleLabel.superview!.frame.width / 3)
            make.top.equalTo(titleLabel.superview!)
        }
    }
    
    private func configSaveButtonConstraints() {
        saveButton.snp.makeConstraints { make in
            make.bottom.equalTo(saveButton.superview!)
            make.height.equalTo(superview!.frame.height / Constants.tableRowHeightDivisor)
            make.left.equalTo(saveButton.superview!)
            make.width.equalTo(saveButton.superview!)
        }
        
        saveButton.layoutIfNeeded()
        
        saveButtonLabel.snp.makeConstraints { make in
            make.center.equalTo(saveButton)
            make.height.equalTo(saveButton)
            make.width.equalTo(saveButton.frame.width / 4)
        }
    }
    
    private func addtitleLabel() {
        addSubview(titleLabel)
        
        titleLabel.font = Constants.responsiveDefaultFont
        titleLabel.text = "Settings"
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.numberOfLines = 1
        titleLabel.baselineAdjustment = .alignCenters
        titleLabel.textColor = Constants.colorBlack
    }
    
    private func addSaveButton() {
        addSubview(saveButton)
        
        saveButton.addSubview(saveButtonLabel)
        saveButton.backgroundColor = Constants.colorGreen
        
        saveButtonLabel.text = "SAVE"
        saveButtonLabel.font = Constants.responsiveDefaultFont
        saveButtonLabel.textAlignment = .center
        saveButtonLabel.adjustsFontSizeToFitWidth = true
        saveButtonLabel.numberOfLines = 1
        saveButtonLabel.baselineAdjustment = .alignCenters
        saveButtonLabel.textColor = Constants.colorWhite
        
        addSaveButtonTapRecognizer()
    }
    
    private func addSaveButtonTapRecognizer() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onSave))
        
        tapRecognizer.delegate = self as? UIGestureRecognizerDelegate
        
        saveButton.addGestureRecognizer(tapRecognizer)
    }
}
