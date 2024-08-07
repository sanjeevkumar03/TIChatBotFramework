// VASettingsVC
// Copyright © 2021 Telus International. All rights reserved.

import UIKit
import IQKeyboardManagerSwift

class VASettingsVC: UIViewController {

    // MARK: - Outlet declaration
    @IBOutlet weak var channelContainer: UIView!
    @IBOutlet weak var languageContainer: UIView!
    @IBOutlet weak var languagelabel: UILabel!
    @IBOutlet weak var channellabel: UILabel!
    @IBOutlet weak var selectLanguageLbl: UILabel!
    @IBOutlet weak var selectChannelLbl: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var viewNavigation: UIView!
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var imgBack: UIImageView!
    @IBOutlet weak var viewHeaderSeperator: UIView!
    @IBOutlet weak var imgChannelDropdown: UIImageView!
    @IBOutlet weak var imgLanguageDropdown: UIImageView!
    @IBOutlet weak var viewChannel: UIView!
    @IBOutlet weak var viewLanguage: UIView!
    @IBOutlet weak var viewTextToSpeech: UIView!
    @IBOutlet weak var viewChatTranscript: UIView!
    @IBOutlet weak var lblTextToSpeech: UILabel!
    @IBOutlet weak var lblEnableTextToSpeech: UILabel!
    @IBOutlet weak var switchTextToSpeech: UISwitch!
    @IBOutlet weak var lblChatTranscript: UILabel!
    @IBOutlet weak var lblSendChatTranscript: UILabel!
    @IBOutlet weak var transcriptEmailTF: UITextField!
    @IBOutlet weak var sendTranscriptMailButton: UIButton!

    // MARK: - Property declaration
    var languageSelected = ""
    var channelSelected = ""
    var selectedLanguageString: String = ""
    var isTextToSpeechEnable: Bool = true
    var configIntegrationModel: VAConfigIntegration?
    var chatTranscriptEnabled: Bool = false
    var oldSelectedLanguage: String = ""
    var fontName: String = ""
    var textFontSize: Double = 0.0

    // MARK: - UIViewController Lify Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.configureUIWithColor()

        self.lblHeader.text = LanguageManager.shared.localizedString(forKey: "Widget Settings")
        self.transcriptEmailTF.placeholder = LanguageManager.shared.localizedString(forKey: "Please Enter Email")

        self.channelContainer.roundedShadowView(cornerRadius: 8, borderWidth: 1, borderColor: VAColorUtility.defaultThemeTextIconColor)

        self.languageContainer.roundedShadowView(cornerRadius: 8, borderWidth: 1, borderColor: VAColorUtility.defaultThemeTextIconColor)

        self.transcriptEmailTF.roundedShadowView(cornerRadius: 8, borderWidth: 1, borderColor: VAColorUtility.defaultThemeTextIconColor)

        self.getCurrentLanguage()

        self.btnBack.setTitle("", for: .normal)

        self.transcriptEmailTF.isUserInteractionEnabled = configIntegrationModel?.editEmail ?? true

        self.transcriptEmailTF.text = VAConfigurations.customData?.email

        if VAConfigurations.isChatTool {
            /// don't show channel, text to speech and transcript options for ChatTool
            self.viewChannel.isHidden = true
            self.viewTextToSpeech.isHidden = true
            self.viewChatTranscript.isHidden = true
        } else {
            if self.chatTranscriptEnabled && !(self.transcriptEmailTF.text?.isEmpty ?? true) {
                // show chat transcript
                self.viewChatTranscript.isHidden = false
            } else {
                // hide   chat transcript
                self.viewChatTranscript.isHidden = true
            }
        }
        /// Disabling  text to speech for now. Delete below line once it is implemented
        self.viewTextToSpeech.isHidden = true

        self.saveButton.layer.cornerRadius = 8.0
        self.setLocalization()
        self.overrideUserInterfaceStyle = .light
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.toolbarConfiguration.placeholderConfiguration.showPlaceholder = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = false
    }
    // end

    // MARK: - Get Current Language
    /// This function is used to get the current language
    func getCurrentLanguage() {
        let filteredData = VAConfigurations.arrayOfLanguages.filter { languageModel in
            if languageModel.lang == VAConfigurations.getCurrentLanguageCode() {
                return true
            } else {
                return false
            }
        }

        if filteredData.count > 0 {
            self.languagelabel.text = filteredData[0].displayName
        } else {

            self.languagelabel.text = "English"
        }
        oldSelectedLanguage = self.languagelabel.text ?? ""
    }
    // end

    // MARK: Localization
    func setLocalization() {
        selectLanguageLbl.text = LanguageManager.shared.localizedString(forKey: "Select Language")

        selectChannelLbl.text = LanguageManager.shared.localizedString(forKey: "Select Channel")

        saveButton.setTitle(LanguageManager.shared.localizedString(forKey: "Save"), for: .normal)

        self.lblTextToSpeech.text = LanguageManager.shared.localizedString(forKey: "Text to speech")

        self.lblEnableTextToSpeech.text = LanguageManager.shared.localizedString(forKey: "Enable text to speech")

        self.lblChatTranscript.text = LanguageManager.shared.localizedString(forKey: "Chat Transcript")

        self.lblSendChatTranscript.text = LanguageManager.shared.localizedString(forKey: "Send Chat Transcript to your email address")
        self.channellabel.text = LanguageManager.shared.localizedString(forKey: "Mobile")
        self.channelSelected = LanguageManager.shared.localizedString(forKey: "Mobile")
    }
    // end

    // MARK: - Configure the UI with custom UIColor
    /// This function is used to configure UI
    func configureUIWithColor() {
        // Background Color
        self.view.backgroundColor = VAColorUtility.white// VAColorUtility.themeColor

        // Header Color
        self.viewNavigation.backgroundColor = VAColorUtility.defaultHeaderColor

        self.imgBack.tintColor = VAColorUtility.defaultButtonColor

        self.lblHeader.textColor =  VAColorUtility.senderBubbleColor

        // Header Seperator Color
        self.viewHeaderSeperator.backgroundColor = VAColorUtility.defaultThemeTextIconColor

        self.saveButton.setTitleColor(VAColorUtility.white, for: .normal)

        self.saveButton.backgroundColor = VAColorUtility.senderBubbleColor

        self.imgChannelDropdown.tintColor = VAColorUtility.senderBubbleColor

        self.imgLanguageDropdown.tintColor = VAColorUtility.senderBubbleColor

        if VAConfigurations.isTextToSpeechEnable {
            self.switchTextToSpeech.isOn = true
        } else {
            self.switchTextToSpeech.isOn = false
        }

        self.switchTextToSpeech.onTintColor = VAColorUtility.senderBubbleColor

        self.switchTextToSpeech.tintColor = VAColorUtility.receiverBubbleColor

        self.switchTextToSpeech.layer.cornerRadius = self.switchTextToSpeech.frame.height / 2.0

        self.switchTextToSpeech.backgroundColor = VAColorUtility.receiverBubbleColor

        self.sendTranscriptMailButton.backgroundColor = VAColorUtility.senderBubbleColor

        self.switchTextToSpeech.clipsToBounds = true

        self.sendTranscriptMailButton.tintColor = .white

        self.sendTranscriptMailButton.layer.cornerRadius = self.sendTranscriptMailButton.frame.height / 2

        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: self.transcriptEmailTF.frame.size.height))

        self.transcriptEmailTF.leftView = paddingView

        self.transcriptEmailTF.leftViewMode = .always

        self.lblHeader.font =  UIFont(name: fontName, size: textFontSize)
        self.transcriptEmailTF.font =  UIFont(name: fontName, size: textFontSize)
        self.sendTranscriptMailButton.titleLabel?.font =  UIFont(name: fontName, size: textFontSize)
        self.saveButton.titleLabel?.font =  UIFont(name: fontName, size: textFontSize)
        self.selectChannelLbl.font =  UIFont(name: fontName, size: textFontSize)
        self.selectLanguageLbl.font =  UIFont(name: fontName, size: textFontSize)
        self.channellabel.font =  UIFont(name: fontName, size: textFontSize)
        self.languagelabel.font =  UIFont(name: fontName, size: textFontSize)
        self.lblChatTranscript.font =  UIFont(name: fontName, size: textFontSize)
        self.lblSendChatTranscript.font =  UIFont(name: fontName, size: textFontSize)
    }
    // end

    // MARK: - Present List Popover View
    func presentListingPopover(forChannel: Bool, sender: UIButton) {
        if forChannel {
            let mobile = LanguageManager.shared.localizedString(forKey: "Mobile")
            VAPopoverListVC.openPopoverListView(arrayOfData: [mobile], viewController: self, sender: imgChannelDropdown, fontName: self.fontName, textFontSize: self.textFontSize) { (_, item) in
                self.channellabel.text = item
                self.channelSelected = item
            }
        } else {

            var array: [String] = []
            for item in VAConfigurations.arrayOfLanguages {
                array.append(item.displayName ?? "")
            }

            VAPopoverListVC.openPopoverListView(arrayOfData: array, viewController: self, sender: imgLanguageDropdown, fontName: self.fontName, textFontSize: self.textFontSize) { (index, item) in
                self.selectedLanguageString = item
                self.languageSelected =  VAConfigurations.arrayOfLanguages[index].lang ?? ""
                self.languagelabel.text = self.selectedLanguageString
            }
        }
    }
    // end

    // MARK: - IBActions
    /// This function is used when user clicked on Channel button
    @IBAction func channelBtnClicked(_ sender: UIButton) {
        self.presentListingPopover(forChannel: true, sender: sender)
    }

    /// This function is used when user clicked on Language button
    @IBAction func languageBtnClicked(_ sender: UIButton) {
        self.presentListingPopover(forChannel: false, sender: sender)
    }

    /// This function is used when user clicked on back button
    @IBAction func btnBackTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    /// This function is called when user  change the value of TextToSpeech UISwitch
    @IBAction func valueChangedTextToSpeech(_ sender: Any) {
        if let value = sender as? UISwitch {
            if value.isOn {
                self.isTextToSpeechEnable = true
            } else {
                self.isTextToSpeechEnable = false
            }
        }
    }

    /// This function is called when user clicked on Save button
    @IBAction func saveBtnClicked(_ sender: UIButton) {
        DispatchQueue.main.async {
            // UIView.appearance().semanticContentAttribute = .forceLeftToRight
            if self.selectedLanguageString.lowercased() == "english" {
                VAConfigurations.language = .english
            } else if self.selectedLanguageString.lowercased() == "traditional chinese" {
                VAConfigurations.language = .chineseTraditional
            } else if self.selectedLanguageString.lowercased() == "simplified chinese" {
                VAConfigurations.language = .chineseSimplified
            } else if self.selectedLanguageString.lowercased() == "french" {
                VAConfigurations.language = .french
            } else if self.selectedLanguageString.lowercased() == "german" {
                VAConfigurations.language = .german
            } else if self.selectedLanguageString.lowercased() == "spanish" {
                VAConfigurations.language = .spanish
            } else if self.selectedLanguageString.lowercased() == "dutch"{
                VAConfigurations.language = .dutch
            } else if self.selectedLanguageString.lowercased() == "tagalog"{
                VAConfigurations.language = .tagalog
            } else if self.selectedLanguageString.lowercased() == "turkish"{
                VAConfigurations.language = .turkish
            } else if self.selectedLanguageString.lowercased() == "punjabi"{
                VAConfigurations.language = .punjabi
            } else if self.selectedLanguageString.lowercased() == "japanese"{
                VAConfigurations.language = .japanese
            } else if self.selectedLanguageString.lowercased() == "persian"{
                VAConfigurations.language = .persian
                // UIView.appearance().semanticContentAttribute = .forceRightToLeft
            }
            if self.oldSelectedLanguage != self.selectedLanguageString {
                NotificationCenter.default.post(name: Notification.Name("LanguageChangedFromSettings"), object: nil)
                UserDefaultsManager.shared.setBotLanguage(VAConfigurations.language?.rawValue ?? "")
                self.setLocalization()

            }
            // self.viewModel.autoDetectedLanguageId = ""
            VAConfigurations.isTextToSpeechEnable = self.isTextToSpeechEnable
            self.navigationController?.popViewController(animated: true)
        }

    }

    /// This function is called when user clicked on send chat transcript button
    @IBAction func sendChatTranscriptBtnAction(_ sender: Any) {
        self.view.endEditing(true)
        let sessionId = UserDefaultsManager.shared.getSessionID()
        if sessionId == "" || sessionId == "0" {
            return
        }
        // Check email is empty or not
        if self.transcriptEmailTF.text?.isEmpty ?? false {
            // Show alert
            UIAlertController.openAlertWithOk(LanguageManager.shared.localizedString(forKey: "Error"),
                                              LanguageManager.shared.localizedString(forKey: "Please Enter Email"),
                                              LanguageManager.shared.localizedString(forKey: "OK"),
                                              view: self,
                                              completion: nil)
        } else {
            // Check is email valid
            if isValidEmail(email: self.transcriptEmailTF.text!) == true {
                // Show Loader
                CustomLoader.show()
                // Call Api
                APIManager.sharedInstance.postTranscript(
                    botId: VAConfigurations.botId,
                    email: transcriptEmailTF.text ?? "",
                    language: VAConfigurations.language?.rawValue ?? "",
                    sessionId: sessionId,
                    user: VAConfigurations.userJid) { (resultStr) in
                        DispatchQueue.main.async {
                            // Hide Loader
                            CustomLoader.hide()
                            // Show Success alert
                            UIAlertController.openAlertWithOk(LanguageManager.shared.localizedString(forKey: "Email Sent"),
                                                              resultStr,
                                                              LanguageManager.shared.localizedString(forKey: "OK"),
                                                              view: self) {
                            }
                        }
                    }
            } else {
                // Show alert
                UIAlertController.openAlertWithOk(LanguageManager.shared.localizedString(forKey: "Error"),
                                                  LanguageManager.shared.localizedString(forKey: "Please enter valid email"),
                                                  LanguageManager.shared.localizedString(forKey: "OK"), 
                                                  view: self,
                                                  completion: nil)
            }
        }
    }
}
