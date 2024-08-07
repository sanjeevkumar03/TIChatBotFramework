// VAChatTranscriptVC
// Copyright © 2021 Telus International. All rights reserved.

import UIKit

class VAChatTranscriptVC: UIViewController {
    // MARK: Outlet declaration
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var imgHeaderLogo: UIImageView!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var feedbackTitleLabel: UILabel!
    @IBOutlet weak var transcriptTitleLabel: UILabel!
    @IBOutlet weak var sendChatLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var sendTranscriptMailButton: UIButton!
    @IBOutlet weak var closeButtonBottom: NSLayoutConstraint!

    // MARK: Property declaration
    var fontName: String = ""
    var textFontSize: Double = 0.0
    var configIntegrationModel: VAConfigIntegration?
    var isFeedbackSkipped: Bool = false
    var configResulModel: VAConfigResultModel?

    // MARK: View controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.setUI()
        self.overrideUserInterfaceStyle = .light
    }

    // MARK: Custom methods
    func setUI() {
        self.setupHeaderImageAndTitle()
        self.setLocalization()
        if self.view.safeAreaInsets.bottom > 0 {
            self.closeButtonBottom.constant = 0
        } else {
            self.closeButtonBottom.constant = 16
        }
        self.lblHeader.textColor = VAColorUtility.defaultButtonColor
        self.emailTF.text = VAConfigurations.customData?.email
        
        if emailTF.text?.isEmpty ?? true {
            emailTF.isUserInteractionEnabled = true
        } else {
            emailTF.isUserInteractionEnabled = false
        }

        self.closeButton.layer.cornerRadius = 8.0
        self.closeButton.setTitleColor(VAColorUtility.white, for: .normal)
        self.closeButton.backgroundColor = VAColorUtility.senderBubbleColor
        self.sendTranscriptMailButton.tintColor = VAColorUtility.senderBubbleColor
        self.feedbackTitleLabel.textColor = VAColorUtility.senderBubbleColor

        self.transcriptTitleLabel.textColor = VAColorUtility.themeTextIconColor
        self.sendChatLabel.textColor = VAColorUtility.themeTextIconColor
        self.emailTF.textColor = VAColorUtility.themeTextIconColor
        var boldFont = ""
        let fontArray = fontName.components(separatedBy: "-")
        if fontArray.count > 1 {
            boldFont = fontArray.first! + "-Bold"
        } else {
            boldFont = fontName + "-Bold"
        }
        let isBoldFont = UIFont(name: boldFont, size: textFontSize)?.isBold
        if isBoldFont == true {
            self.feedbackTitleLabel.font = UIFont(name: boldFont, size: (textFontSize + 4))
            self.transcriptTitleLabel.font = UIFont(name: boldFont, size: textFontSize)
        } else {
            self.feedbackTitleLabel.font = UIFont.boldSystemFont(ofSize: textFontSize + 4)
            self.transcriptTitleLabel.font = UIFont.boldSystemFont(ofSize: textFontSize)
        }
        self.sendChatLabel.font = UIFont(name: fontName, size: textFontSize)
        self.emailTF.font = UIFont(name: fontName, size: textFontSize)
        self.closeButton.titleLabel?.font = UIFont(name: fontName, size: textFontSize)
    }
    func setLocalization() {
        feedbackTitleLabel.text = LanguageManager.shared.localizedString(forKey: isFeedbackSkipped ? "Thank You" : "Thanks for your feedback!")
        transcriptTitleLabel.text = LanguageManager.shared.localizedString(forKey: "Chat Transcript")
        sendChatLabel.text = LanguageManager.shared.localizedString(forKey: "Send Chat Transcript to your email address")
        emailTF.placeholder = LanguageManager.shared.localizedString(forKey: "Please Enter Email")
        closeButton.setTitle(LanguageManager.shared.localizedString(forKey: "Close"), for: .normal)
    }
    
    // MARK: - Set up header image and title
    /// This function is used to update header image and title
    func setupHeaderImageAndTitle() {
        // Header Title
        self.lblHeader.text = configResulModel?.name ?? ""
        self.lblHeader.font = UIFont(name: fontName, size: textFontSize)
        // Header Image
        if configResulModel?.headerLogo?.isEmpty ?? true {
            self.imgHeaderLogo?.image = UIImage(named: "flashImage", in: Bundle(for: VAChatViewController.self), with: nil)
        } else {
            ImageDownloadManager().loadImage(imageURL: configResulModel?.headerLogo ?? "") {[weak self] (_, downloadedImage) in
                if let img = downloadedImage {
                    DispatchQueue.main.async {
                        self?.imgHeaderLogo?.image = img
                    }
                }
            }
        }
    }

    // MARK: Button Actions
    // This function is used when user tapped on close Button
    @IBAction func closeBtnAction(_ sender: Any) {
        self.closeChatbot()
    }

    // This function is used when user tapped on Send Button
    @IBAction func sendBtnAction(_ sender: Any) {
        self.view.endEditing(true)
        // check if email textfield is empty or not
        if emailTF.text?.isEmpty ?? false {
            // show alert
            UIAlertController.openAlertWithOk(LanguageManager.shared.localizedString(forKey: "Error"),
                                              LanguageManager.shared.localizedString(forKey: "Please Enter Email"),
                                              LanguageManager.shared.localizedString(forKey: "OK"), view: self,
                                              completion: nil)
        } else {
            /// check for valid email
            if isValidEmail(email: emailTF.text!) == true {
                // api call
                APIManager.sharedInstance.postTranscript(
                    botId: VAConfigurations.botId,
                    email: emailTF.text ?? "",
                    language: VAConfigurations.getCurrentLanguageCode(),
                    sessionId: UserDefaultsManager.shared.getSessionID(),
                    user: VAConfigurations.userJid) { (resultStr) in
                        DispatchQueue.main.async {
                            // show success alert
                            UIAlertController.openAlertWithOk(LanguageManager.shared.localizedString(forKey: "Email Sent"),
                                                              resultStr,
                                                              LanguageManager.shared.localizedString(forKey: "OK"),
                                                              view: self) {
                                self.closeChatbot()
                            }
                        }
                    }
            } else {
                // show error alert
                UIAlertController.openAlertWithOk(LanguageManager.shared.localizedString(forKey: "Error"),
                                                  LanguageManager.shared.localizedString(forKey: "Please enter valid email"),
                                                  LanguageManager.shared.localizedString(forKey: "OK"), view: self, 
                                                  completion: nil)
            }
        }
    }
    private func closeChatbot() {
        UserDefaultsManager.shared.resetAllUserDefaults()
        VAConfigurations.virtualAssistant?.delegate?.didTapCloseChatbot()
        CustomLoader.hide()
        if self.parent?.parent == nil {
            self.dismiss(animated: false) {
            }
        } else {
            if self.parent?.children.count ?? 0 > 0 {
                let viewControllers: [UIViewController] = self.parent!.children
                for viewContoller in viewControllers {
                    viewContoller.willMove(toParent: nil)
                    viewContoller.view.removeFromSuperview()
                    viewContoller.removeFromParent()
                }
            }
        }
    }
}
// end

// MARK: UITextFieldDelegate
extension VAChatTranscriptVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
// end
