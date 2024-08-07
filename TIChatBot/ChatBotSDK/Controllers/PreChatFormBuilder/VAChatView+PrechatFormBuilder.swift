
//  VAChatView+PrechatFormBuilder.swift
//  Created by Sanjeev Kumar on 07/05/24.
//  Copyright © 2024 Telus International. All rights reserved.

import Foundation
import UIKit

extension VAChatViewController {
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?){
        if(keyPath == "contentSize"){
            if let newvalue = change?[.newKey]{
                let newsize  = newvalue as! CGSize
                if newsize.height > UIScreen.main.bounds.height * 0.6 {
                    self.prechatFormTableHeight.constant = UIScreen.main.bounds.height * 0.6
                } else {
                    self.prechatFormTableHeight.constant = newsize.height
                }
            }
        }
    }
    
    //MARK: Custom methods
    func configurePreChatFormTable() {
        preChatFormTable.showsVerticalScrollIndicator = false
        preChatFormTable.register(UINib(nibName: TextFieldFormCell.nibName, bundle: Bundle(for: VAChatViewController.self)), forCellReuseIdentifier: TextFieldFormCell.cellIdentifier)
        preChatFormTable.register(UINib(nibName: TextAreaFormCell.nibName, bundle: Bundle(for: VAChatViewController.self)), forCellReuseIdentifier: TextAreaFormCell.cellIdentifier)
        preChatFormTable.register(UINib(nibName: DropdownFormCell.nibName, bundle: Bundle(for: VAChatViewController.self)), forCellReuseIdentifier: DropdownFormCell.cellIdentifier)
        preChatFormTable.tableFooterView = UIView()
        preChatFormTable.rowHeight = UITableView.automaticDimension
        preChatFormTable.estimatedRowHeight = UITableView.automaticDimension
    }
    
    func configurePreChatFormUI() {
        let buttonColor = #colorLiteral(red: 0.2947866321, green: 0.1562722623, blue: 0.4264383316, alpha: 1)
        self.prechatFormTitle.textColor = buttonColor
        let buttons = [clearFormButton, submitFormButton]
        for button in buttons {
            button?.backgroundColor = .clear
            button?.layer.cornerRadius = 4
            button?.layer.borderColor = buttonColor.cgColor
            button?.layer.borderWidth = 1.0
            button?.setTitleColor(buttonColor, for: .normal)
            button?.setTitleColor(.white, for: .highlighted)
        }
    }
    
    func showPrechatFormAtBotLaunch() {
//        self.showPrechatFormInChatFlow()
//        return
        prechatFormContainer.frame = self.view.bounds
        prechatFormContainer.center = self.view.center
        self.view.addSubview(prechatFormContainer)
        self.view.bringSubviewToFront(prechatFormContainer)
        self.prechatFormBackgroundViewLeading.constant = 0
        self.prechatFormBackgroundViewTrailing.constant = 0
        self.prechatFormBackgroundViewTop.isActive = true
        self.prechatFormBackgroundViewBottom.isActive = true
        self.prechatFormTableHeight.isActive = false
        prechatFormContainer.backgroundColor = .white
        self.prechatFormTitle.text = ""
    }
    
    func showPrechatFormInChatFlow() {
        prechatFormContainer.frame = self.view.bounds
        prechatFormContainer.center = self.view.center
        self.view.addSubview(prechatFormContainer)
        self.view.bringSubviewToFront(prechatFormContainer)
        self.prechatFormBackgroundViewLeading.constant = 16
        self.prechatFormBackgroundViewTrailing.constant = 16
        self.prechatFormBackgroundViewTop.isActive = false
        self.prechatFormBackgroundViewBottom.isActive = false
        self.prechatFormTableHeight.isActive = true
        prechatFormContainer.backgroundColor = #colorLiteral(red: 0.2272125483, green: 0.2371562719, blue: 0.2465391159, alpha: 1).withAlphaComponent(0.75)
        self.prechatFormTitle.text = "Pre-chat form"
        self.preChatFormTable.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }
    
    func removeUserInputsFromForm() {
        let props = self.viewModel.prechatForm?.settings?.props?.map({
            var dict = $0
            dict.userInputValue = ""
            return dict
        })
        self.viewModel.prechatForm?.settings?.props = props
    }
    
    func updatePreChatFormTableOnUserInput(_ text: String, hasValidInput: Bool, at index: Int) {
        self.viewModel.prechatForm?.settings?.props?[index].userInputValue = text
        self.viewModel.prechatForm?.settings?.props?[index].hasValidUserInput = hasValidInput
        UIView.performWithoutAnimation {
            preChatFormTable.beginUpdates()
            preChatFormTable.endUpdates()
        }
    }

    func removePreChatFormView() {
        self.prechatFormContainer.removeFromSuperview()
        if isPreChatFormShownInFlow {
            self.preChatFormTable.removeObserver(self, forKeyPath: "contentSize")
        }
    }
    
    //MARK: Button Actions
    
    @IBAction func clearPreChatFormButtonTouchDown(_ sender: UIButton) {
        sender.backgroundColor = #colorLiteral(red: 0.2947866321, green: 0.1562722623, blue: 0.4264383316, alpha: 1)
    }
    
    @IBAction func submitPreChatFormButtonTouchDown(_ sender: UIButton) {
        sender.backgroundColor = #colorLiteral(red: 0.2947866321, green: 0.1562722623, blue: 0.4264383316, alpha: 1)
    }
    
    @IBAction func clearPreChatFormTapped(_ sender: UIButton) {
        sender.backgroundColor = .white
        self.hasErrorsInPrechatFormDuringSubmit = false
        self.removeUserInputsFromForm()
        self.preChatFormTable.reloadData()
    }

    @IBAction func submitPreChatFormTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        sender.backgroundColor = .white
        self.hasErrorsInPrechatFormDuringSubmit = false
        var props = self.viewModel.prechatForm?.settings?.props
        ///Exclude optional fields
        props = props?.map({
            var dict = $0
            if dict.propRequired == false {
                var maxLength = getFormFieldMaxLength(length: dict.maxLength)
                if maxLength == 0 {
                    maxLength = 1000
                }
                if (dict.userInputValue?.count ?? 0) > maxLength {
                    dict.hasValidUserInput = false
                }else if (dict.validation?.isEmpty ?? false) {
                    dict.hasValidUserInput = true
                } else if (!(dict.validation?.isEmpty ?? false)  && (dict.userInputValue?.isEmpty ?? false)) {
                    dict.hasValidUserInput = true
                }
            }
            return dict
        })
        let hasInvalidInput = props?.filter({$0.hasValidUserInput == false}).count ?? 0 > 0
        if hasInvalidInput {
            ///Show errors in pre chat form
            self.hasErrorsInPrechatFormDuringSubmit = true
            self.preChatFormTable.reloadData()
            return
        }
        ///Filter out all user inputs
        for index in 0..<(props?.count ?? 0) {
            if let prop = props?[index] {
                if prop.inputType?.label == PreChatFormFieldType.dropDown {
                    let selectedValue = prop.options?.filter({$0.label?.trimmingCharacters(in: .whitespacesAndNewlines) == prop.userInputValue})
                    self.viewModel.prechatFormUserInputs?["\(prop.inputName ?? "")"] = selectedValue?.first?.value ?? ""
                } else {
                    if prop.inputName?.lowercased() == "email" {
                        VAConfigurations.customData?.email = prop.userInputValue ?? ""
                    }else if prop.inputName?.lowercased() == "username" {
                        VAConfigurations.customData?.userName = prop.userInputValue ?? ""
                    }
                    self.viewModel.prechatFormUserInputs?["\(prop.inputName ?? "")"] = prop.userInputValue ?? ""
                }
            }
        }
        self.removeUserInputsFromForm()
        UIView.performWithoutAnimation {
            self.preChatFormTable.reloadData()
        }
        self.removePreChatFormView()
        /*if !(VAConfigurations.customData?.isGroupSSO ?? false) {
            ///Staring new session when opening prechat form
            UserDefaultsManager.shared.resetUserUUID()
            VAConfigurations.userUUID = VAConfigurations.generateUUID()
            UserDefaultsManager.shared.resetSessionID()
            UserDefaultsManager.shared.deInitializeChatBot()
        }*/
        self.handleConfigAPIResponse()
    }
    
    @IBAction func closePreChatFormTapped(_ sender: Any) {
        if self.isPreChatFormShownInFlow {
            self.removePreChatFormView()
        } else {
            self.closeChatbot()
        }
    }
}

//MARK: TextFieldFormCellDelegate
extension VAChatViewController: TextFieldFormCellDelegate {
    func didUpdateTextFieldAtIndexPath(_ indexPath: IndexPath, with text: String, hasValidInput: Bool) {
        self.updatePreChatFormTableOnUserInput(text, hasValidInput: hasValidInput, at: indexPath.row)
        
    }
}
//MARK: TextAreaFormCellDelegate
extension VAChatViewController: TextAreaFormCellDelegate {
    func didUpdateTextViewAtIndexPath(_ indexPath: IndexPath, with text: String, hasValidInput: Bool) {
        self.updatePreChatFormTableOnUserInput(text, hasValidInput: hasValidInput, at: indexPath.row)
    }
}
//MARK: DropdownFormCellDelegate
extension VAChatViewController: DropdownFormCellDelegate {
    func didUpdateDropdownAtIndexPath(_ indexPath: IndexPath, with text: String, hasValidInput: Bool) {
        self.updatePreChatFormTableOnUserInput(text, hasValidInput: hasValidInput, at: indexPath.row)
    }
}

