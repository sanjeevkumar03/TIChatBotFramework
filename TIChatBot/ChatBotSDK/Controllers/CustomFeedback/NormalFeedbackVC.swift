// NormalFeedbackVC.swift
// Copyright © 2021 Telus International. All rights reserved.

import UIKit

class NormalFeedbackVC: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var imgHeaderLogo: UIImageView!
    @IBOutlet weak var emj3Button: UIButton!
    @IBOutlet weak var emj2Button: UIButton!
    @IBOutlet weak var emj1Button: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var feedTextViewContainer: UIView!
    @IBOutlet weak var feedTextView: UITextView!
    @IBOutlet weak var lblStaticTitle: UILabel!
    @IBOutlet weak var lblStaticAdditionalFeedback: UILabel!
    @IBOutlet weak var lblFeedbackCharLimit: UILabel!
    @IBOutlet weak var lblStaticResolveIssue: UILabel!
    @IBOutlet weak var radioButtonViewContainer: UIView!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var radioButtonViewContainerHC: NSLayoutConstraint!

    var isAdditionalFeedback: Bool = false
    var ratingScale: Int = 0
    let addtionalFeedbackPlaceholder = LanguageManager.shared.localizedString(forKey: "Feedback Comment")
    var maxCharacterLength: Int = 250
    var chatTranscriptEnabled: Bool = false
    var isIssueResolved: Bool?
    var radioUnselectedImg = UIImage()
    var radioSelectedImg = UIImage()
    var npsSettings: VAConfigNPSSettings?
    var isCustomizeSurveyEnabled: Bool = false
    var fontName: String = ""
    var textFontSize: Double = 0.0
    var configResulModel: VAConfigResultModel?
    // end

    // MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideAdditionalFeedback()
        self.hideRadio()
        self.feedTextView.delegate = self
        self.setLocalization()
        self.setupUI()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.overrideUserInterfaceStyle = .light
    }
    // end

    // MARK: Set Localization
    func setLocalization() {
        yesButton.setTitle(LanguageManager.shared.localizedString(forKey: "YES"), for: .normal)
        yesButton.titleLabel?.minimumScaleFactor = 0.5
        yesButton.titleLabel?.adjustsFontSizeToFitWidth = true
        yesButton.titleLabel?.font = UIFont(name: fontName, size: textFontSize)

        noButton.setTitle(LanguageManager.shared.localizedString(forKey: "NO"), for: .normal)
        noButton.titleLabel?.minimumScaleFactor = 0.5
        noButton.titleLabel?.adjustsFontSizeToFitWidth = true
        noButton.titleLabel?.font = UIFont(name: fontName, size: textFontSize)

        self.lblStaticResolveIssue.text = LanguageManager.shared.localizedString(forKey: "Did we resolve your issue?")
        self.lblStaticResolveIssue.font = UIFont(name: fontName, size: textFontSize)

        if self.chatTranscriptEnabled {
            self.skipButton.setTitle(LanguageManager.shared.localizedString(forKey: "Skip feedback"), for: .normal)
        } else {
            self.skipButton.setTitle(LanguageManager.shared.localizedString(forKey: "Close"), for: .normal)
        }

        self.lblStaticAdditionalFeedback.text = LanguageManager.shared.localizedString(forKey: "Additional Feedback")

        self.lblStaticTitle.text = LanguageManager.shared.localizedString(forKey: "Regarding the TELUS Virtual Assistant that just helped you, how would you rate its performance?")

        self.submitButton.setTitle(LanguageManager.shared.localizedString(forKey: "Submit"), for: .normal)
    }
    // end
    
    func setupUI() {
        self.setupHeaderImageAndTitle()
        self.lblHeader.textColor = VAColorUtility.defaultButtonColor
        self.lblHeader.font = UIFont(name: fontName, size: textFontSize)
        self.lblStaticTitle.textColor = VAColorUtility.themeTextIconColor
        self.lblStaticTitle.font = UIFont(name: fontName, size: textFontSize)
        self.lblStaticAdditionalFeedback.textColor = VAColorUtility.themeTextIconColor
        self.lblStaticAdditionalFeedback.font = UIFont(name: fontName, size: textFontSize)
        self.submitButton.layer.cornerRadius = 10
        self.submitButton.layer.borderWidth = 1
        self.submitButton.layer.borderColor = VAColorUtility.senderBubbleColor.cgColor
        self.submitButton.setTitleColor(VAColorUtility.senderBubbleColor, for: .normal)
        self.submitButton.isUserInteractionEnabled = false
        self.submitButton.backgroundColor = VAColorUtility.clear
        self.submitButton.titleLabel?.font = UIFont(name: fontName, size: textFontSize)
        
        self.skipButton.setTitleColor(VAColorUtility.themeTextIconColor, for: .normal)
        self.skipButton.titleLabel?.font = UIFont(name: fontName, size: textFontSize)
        
        self.emj1Button.tintColor = VAColorUtility.senderBubbleColor
        self.emj2Button.tintColor = VAColorUtility.senderBubbleColor
        self.emj3Button.tintColor = VAColorUtility.senderBubbleColor
        
        emj1Button.setImage(UIImage(named: "emoji4", in: Bundle(for: NormalFeedbackVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        emj2Button.setImage(UIImage(named: "emoji6", in: Bundle(for: NormalFeedbackVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        emj3Button.setImage(UIImage(named: "emoji7", in: Bundle(for: NormalFeedbackVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        radioUnselectedImg = UIImage(named: "radio-unChecked", in: Bundle(for: NormalFeedbackVC.self), compatibleWith: nil)!.withRenderingMode(.alwaysTemplate)
        radioSelectedImg = UIImage(named: "radio-checked", in: Bundle(for: NormalFeedbackVC.self), compatibleWith: nil)!.withRenderingMode(.alwaysTemplate)
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) { [self] in
            self.yesButton.tintColor = VAColorUtility.senderBubbleColor
            self.noButton.tintColor = VAColorUtility.senderBubbleColor
            self.yesButton.setImage(self.radioUnselectedImg, for: .normal)
            self.noButton.setImage(radioUnselectedImg, for: .normal)
        }
        self.feedTextView.font = UIFont(name: fontName, size: textFontSize)
        self.lblFeedbackCharLimit.font = UIFont(name: fontName, size: textFontSize)

    }
    // MARK: - Set up header image and title
    /// This function is used to update header image and title
    func setupHeaderImageAndTitle() {
        // Header Title
        self.lblHeader.text = configResulModel?.name ?? ""
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

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    // MARK: - Hide Additional Feedback view
    func hideAdditionalFeedback() {
        feedTextViewContainer.isHidden = true
        feedTextViewContainer.backgroundColor = .clear
    }

    // MARK: - Show Additional Feedback view
    func showAdditionalFeedback() {
        // self.view.endEditing(true)
        self.feedTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        self.feedTextView.text = self.addtionalFeedbackPlaceholder
        self.feedTextView.textColor = UIColor.lightGray
        // self.feedTextView.roundedShadowView(cornerRadius: 10, borderWidth: 1, borderColor: isCustomizeSurveyEnabled ? VAColorUtility.themeTextIconColor : VAColorUtility.defaultThemeTextIconColor)
        self.feedTextView.roundedShadowView(cornerRadius: 10, borderWidth: 1, borderColor: VAColorUtility.themeTextIconColor)
        self.feedTextViewContainer.isHidden = false
    }
    // MARK: - Hide Radio buttons YES or NO
    func hideRadio() {
        self.radioButtonViewContainer.isHidden = true
        self.radioButtonViewContainerHC.constant = 0
    }
    // end

    // MARK: - Show Radio buttons YES or NO
    func showRadio() {
        self.radioButtonViewContainer.isHidden = false
        self.radioButtonViewContainerHC.constant = 80
    }
    // end
    
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

    // MARK: - IBAction
    /// This function is used when user clicked on emoji
    @IBAction func emojiBtnAction(_ sender: UIButton) {
        if self.submitButton.backgroundColor != VAColorUtility.senderBubbleColor/*(isCustomizeSurveyEnabled ? VAColorUtility.senderBubbleColor : VAColorUtility.defaultSenderBubbleColor)*/ {
            self.submitButton.layer.cornerRadius = 10
            self.submitButton.layer.borderWidth = 1
//            self.submitButton.layer.borderColor = (isCustomizeSurveyEnabled ? VAColorUtility.senderBubbleColor : VAColorUtility.defaultSenderBubbleColor).cgColor
//            self.submitButton.backgroundColor = (isCustomizeSurveyEnabled ? VAColorUtility.senderBubbleColor : VAColorUtility.defaultSenderBubbleColor)
            self.submitButton.layer.borderColor = VAColorUtility.senderBubbleColor.cgColor
            self.submitButton.backgroundColor = VAColorUtility.senderBubbleColor
            self.submitButton.setTitleColor(VAColorUtility.white, for: .normal)
            self.submitButton.isUserInteractionEnabled = true
        }

        /*if self.feedTextViewContainer.isHidden == true {
            self.showAdditionalFeedback()
        }*/
        // check for feedback text
        if self.feedTextView.text != self.addtionalFeedbackPlaceholder && self.feedTextView.text.count > 0 {
        } else {
            // reset feedTextView
            self.feedTextView.text = ""
            self.feedTextView.endEditing(true)
            // show or hide additional feedback
            if isCustomizeSurveyEnabled  && self.npsSettings?.additionalFeedback ?? false == false {
                hideAdditionalFeedback()
            } else {
                showAdditionalFeedback()
            }
            // self.npsSettings?.additionalFeedback ?? false ? (showAdditionalFeedback()):(hideAdditionalFeedback())
        }
        // show or hide radio button i.e YES or NO on the basic of issue resolved
        self.npsSettings?.issueResolved ?? false ? self.showRadio() : self.hideRadio()

        switch sender.tag {
        case 0:
            emj1Button.setImage(UIImage(named: "emoji4-filled", in: Bundle(for: NormalFeedbackVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
            emj2Button.setImage(UIImage(named: "emoji6", in: Bundle(for: NormalFeedbackVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
            emj3Button.setImage(UIImage(named: "emoji7", in: Bundle(for: NormalFeedbackVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
            self.ratingScale = 3
        case 1:
            emj1Button.setImage(UIImage(named: "emoji4", in: Bundle(for: NormalFeedbackVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
            emj2Button.setImage(UIImage(named: "emoji6-filled", in: Bundle(for: NormalFeedbackVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
            emj3Button.setImage(UIImage(named: "emoji7", in: Bundle(for: NormalFeedbackVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
            self.ratingScale = 7
        case 2:
            emj1Button.setImage(UIImage(named: "emoji4", in: Bundle(for: NormalFeedbackVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
            emj2Button.setImage(UIImage(named: "emoji6", in: Bundle(for: NormalFeedbackVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
            emj3Button.setImage(UIImage(named: "emoji7-filled", in: Bundle(for: NormalFeedbackVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
            self.ratingScale = 9
        default:
            print("")
        }
    }
    
    func moveToChatTranscriptScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle(for: NormalFeedbackVC.self))
        if let vcObj = storyboard.instantiateViewController(withIdentifier: "VAChatTranscriptVC") as? VAChatTranscriptVC {
            vcObj.textFontSize = self.textFontSize
            vcObj.fontName = self.fontName
            vcObj.configResulModel = self.configResulModel
            self.navigationController?.pushViewController(vcObj, animated: false)
        }
    }

    /// This function is called when user tapped on submit button
    @IBAction func submitBtnAction(_ sender: Any) {
        var feedbackMsg: String = ""
        if self.feedTextView.text == self.addtionalFeedbackPlaceholder {
            feedbackMsg = ""
        } else {
            feedbackMsg = self.feedTextView.text
        }
        var strIssueResolved: String = ""
        self.isIssueResolved == nil ? (strIssueResolved = "") : (self.isIssueResolved == true ? (strIssueResolved = "true"): ( strIssueResolved = "false"))
        // Call Api
        APIManager.sharedInstance.submitNPSSurveyFeedback(reason: [],
                                                          score: self.ratingScale,
                                                          feedback: feedbackMsg,
                                                          issueResolved: strIssueResolved) { (resultStr) in
            DispatchQueue.main.async {
                // Show Alert
                UIAlertController.openAlertWithOk(LanguageManager.shared.localizedString(forKey: "Message!"), resultStr, LanguageManager.shared.localizedString(forKey: "OK"), view: self) {
                    if self.chatTranscriptEnabled == true { // Open VAChatTranscriptVC
                        self.moveToChatTranscriptScreen()
                    } else { // Close the ChatBot
                        self.closeChatbot()
                    }
                }
            }
        }
    }

    /// This function is called when user tapped on Close button
    @IBAction func closeBtnAction(_ sender: Any) {
        if self.chatTranscriptEnabled == true {
            self.moveToChatTranscriptScreen()
        } else {
            self.closeChatbot()
        }
    }

    /// This function is used when user tap no button
    @IBAction func noBtnAction(_ sender: UIButton) {
        self.yesButton.setImage(radioUnselectedImg, for: .normal)
        self.noButton.setImage(radioSelectedImg, for: .normal)
        self.isIssueResolved = false
    }

    /// This function is used when user tap yes button
    @IBAction func yesBtnAction(_ sender: UIButton) {
        self.yesButton.setImage(radioSelectedImg, for: .normal)
        self.noButton.setImage(radioUnselectedImg, for: .normal)
        self.isIssueResolved = true
    }
}

// MARK: - NormalFeedbackVC extension of UITextViewDelegate
extension NormalFeedbackVC: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)

        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        if newText.count <= self.maxCharacterLength {
            self.lblFeedbackCharLimit.text = "\(newText.count)/\(self.maxCharacterLength)"
        }
        let maxLength =  self.maxCharacterLength
        return newText.count <= maxLength
    }

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text == self.addtionalFeedbackPlaceholder {
            textView.text = ""
            // self.feedTextView.textColor = isCustomizeSurveyEnabled ? VAColorUtility.themeTextIconColor : VAColorUtility.defaultThemeTextIconColor
            self.feedTextView.textColor = VAColorUtility.themeTextIconColor
        }
        return true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            textView.text = self.addtionalFeedbackPlaceholder
            self.feedTextView.textColor = UIColor.lightGray
        }
    }
}
// end
