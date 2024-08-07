// FeedbackSurveyVC.swift
// Copyright © 2021 Telus International. All rights reserved.

import UIKit
import IQKeyboardManagerSwift

class FeedbackSurveyVC: UIViewController {

    // MARK: - Outlet declaration
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var imgHeaderLogo: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var ratingsTitleLblHC: NSLayoutConstraint!
    @IBOutlet weak var ratingsTitleLbl: UILabel!
    @IBOutlet weak var oneButton: UIButton!
    @IBOutlet weak var twoButton: UIButton!
    @IBOutlet weak var threeButton: UIButton!
    @IBOutlet weak var fourButton: UIButton!
    @IBOutlet weak var fiveButton: UIButton!
    @IBOutlet weak var sixButton: UIButton!
    @IBOutlet weak var sevenButton: UIButton!
    @IBOutlet weak var eightButton: UIButton!
    @IBOutlet weak var nineButton: UIButton!
    @IBOutlet weak var tenButton: UIButton!
    @IBOutlet weak var oneToFiveSV: UIStackView!
    @IBOutlet weak var sixToNineSV: UIStackView!
    @IBOutlet weak var lblStaticAdditionalFeedback: UILabel!
    @IBOutlet weak var lblStaticResolveIssue: UILabel!

    @IBOutlet weak var answerTagsCollView: UICollectionView! {
        didSet {
            self.answerTagsCollView.delegate = self
            self.answerTagsCollView.dataSource = self
            self.answerTagsCollView.register(UINib(nibName: "AnsTagsCollectionViewCell", bundle: Bundle(for: FeedbackSurveyVC.self)), forCellWithReuseIdentifier: "AnsTagsCollectionViewCell")
            if let flowLayout = self.answerTagsCollView?.collectionViewLayout as? UICollectionViewFlowLayout {
                flowLayout.estimatedItemSize = CGSize(width: 1, height: 1)
            }
        }
    }
    @IBOutlet weak var answerTagsCollHightConst: NSLayoutConstraint!
    @IBOutlet weak var answersTagContainer: UIView!
    @IBOutlet weak var answersTagTitleLabel: UILabel!
    @IBOutlet weak var answersTagTitleLabelTC: NSLayoutConstraint!
    @IBOutlet weak var radioButtonViewContainer: UIView!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var radioButtonViewContainerHC: NSLayoutConstraint!
    @IBOutlet weak var feedTextViewContainer: UIView!
    @IBOutlet weak var feedTextView: UITextView!
    @IBOutlet weak var feedTextViewContainerHC: NSLayoutConstraint!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var viewRatingA: UIView!
    @IBOutlet weak var viewRatingB: UIView!
    @IBOutlet weak var lblHighestRatingA: UILabel!
    @IBOutlet weak var lblLowestRatingA: UILabel!
    @IBOutlet weak var lblHighestRatingB: UILabel!
    @IBOutlet weak var lblLowestRatingB: UILabel!
    @IBOutlet weak var lblFeedbackCharLimit: UILabel!

    // MARK: - Property declaration
    var ansArray = [String]()
    var selectedIndexPath = IndexPath(item: -1, section: -1)
    var selectedTagIndexPath = IndexPath(item: -1, section: -1)
    var npsSettings: VAConfigNPSSettings?
    var ratingScale = 0
    var ratingConfig: VAConfigNPSSettingsData?

    var isFeedbackTypeEmoji = false
    var isAdditionalFeedback = false
    var isAnswersTag = false
    var isRadioShow = true

    var selectedAnswerTagArr = [IndexPath]()
    var selectedAnswerTagValueArr = [String]()
    var score = 0
    var isIssueResolved: Bool?

    var ratingViewOrder: RatingOrder = .ascend
    var additionalFeedbackPlaceholder = ""
    var maxCharacterLimit: Int = 250
    var chatTranscriptEnabled: Bool = false
    var radioUnselectedImg = UIImage()
    var radioSelectedImg = UIImage()
    var fontName: String = ""
    var textFontSize: Double = 0.0
    var configResulModel: VAConfigResultModel?
    
    enum RatingOrder {
        case ascend
        case descend
    }

    // MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        /// Initially hide ratings view, answers section, radio and additional feeback
        self.viewRatingA.isHidden = true
        self.viewRatingB.isHidden = true
        self.hideAnswersTag()
        self.hideRadio()
        self.hideAdditionalFeedback()
        self.setLocalization()
        self.setUI()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.overrideUserInterfaceStyle = .light
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // setup IQkeyboardManager
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.toolbarConfiguration.placeholderConfiguration.showPlaceholder = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // disable IQkeyboardManager
        IQKeyboardManager.shared.enable = false
    }
    // end

    // MARK: Localization
    func setLocalization() {
        yesButton.setTitle(LanguageManager.shared.localizedString(forKey: "YES"), for: .normal)
        yesButton.titleLabel?.minimumScaleFactor = 0.5
        yesButton.titleLabel?.adjustsFontSizeToFitWidth = true

        noButton.setTitle(LanguageManager.shared.localizedString(forKey: "NO"), for: .normal)
        noButton.titleLabel?.minimumScaleFactor = 0.5
        noButton.titleLabel?.adjustsFontSizeToFitWidth = true

        answersTagTitleLabel.text = LanguageManager.shared.localizedString(forKey: "What went well?")

        self.lblStaticAdditionalFeedback.text = LanguageManager.shared.localizedString(forKey: "Additional Feedback")

        self.lblStaticResolveIssue.text = LanguageManager.shared.localizedString(forKey: "Did we resolve your issue?")

        self.submitButton.setTitle(LanguageManager.shared.localizedString(forKey: "Submit"), for: .normal)
        additionalFeedbackPlaceholder = LanguageManager.shared.localizedString(forKey: "Feedback Comment")
    }

    // MARK: - SetUI
    func setUI() {
        // update background color
        self.view.backgroundColor = VAColorUtility.themeColor
        self.yesButton.titleLabel?.font = UIFont(name: fontName, size: textFontSize)
        self.noButton.titleLabel?.font = UIFont(name: fontName, size: textFontSize)
        self.answersTagTitleLabel.font = UIFont(name: fontName, size: textFontSize)
        self.lblStaticAdditionalFeedback.font = UIFont(name: fontName, size: textFontSize)
        self.lblStaticResolveIssue.font = UIFont(name: fontName, size: textFontSize)
        self.submitButton.titleLabel?.font = UIFont(name: fontName, size: textFontSize)
        self.feedTextView.font = UIFont(name: fontName, size: textFontSize)
        self.lblLowestRatingA.font = UIFont(name: fontName, size: textFontSize)
        self.lblLowestRatingB.font = UIFont(name: fontName, size: textFontSize)
        self.lblHighestRatingA.font = UIFont(name: fontName, size: textFontSize)
        self.lblHighestRatingB.font = UIFont(name: fontName, size: textFontSize)
        self.ratingsTitleLbl.font = UIFont(name: fontName, size: textFontSize)
        self.lblFeedbackCharLimit.font = UIFont(name: fontName, size: textFontSize)
        self.skipButton.titleLabel?.font = UIFont(name: fontName, size: textFontSize)

        self.oneButton.titleLabel?.font = UIFont(name: fontName, size: textFontSize)
        self.twoButton.titleLabel?.font = UIFont(name: fontName, size: textFontSize)
        self.threeButton.titleLabel?.font = UIFont(name: fontName, size: textFontSize)
        self.fourButton.titleLabel?.font = UIFont(name: fontName, size: textFontSize)
        self.fiveButton.titleLabel?.font = UIFont(name: fontName, size: textFontSize)
        self.sixButton.titleLabel?.font = UIFont(name: fontName, size: textFontSize)
        self.sevenButton.titleLabel?.font = UIFont(name: fontName, size: textFontSize)
        self.eightButton.titleLabel?.font = UIFont(name: fontName, size: textFontSize)
        self.nineButton.titleLabel?.font = UIFont(name: fontName, size: textFontSize)
        self.tenButton.titleLabel?.font = UIFont(name: fontName, size: textFontSize)

        self.feedTextView.autocorrectionType = .no
        self.lblHeader.textColor = VAColorUtility.defaultButtonColor
        self.lblHeader.font = UIFont(name: fontName, size: textFontSize)

        self.lblStaticAdditionalFeedback.textColor = VAColorUtility.themeTextIconColor
        self.lblStaticResolveIssue.textColor = VAColorUtility.themeTextIconColor
        self.lblLowestRatingA.textColor = VAColorUtility.themeTextIconColor
        self.lblLowestRatingB.textColor = VAColorUtility.themeTextIconColor
        self.lblHighestRatingA.textColor = VAColorUtility.themeTextIconColor
        self.lblHighestRatingB.textColor = VAColorUtility.themeTextIconColor
        self.ratingsTitleLbl.textColor = VAColorUtility.themeTextIconColor
        self.lblFeedbackCharLimit.textColor = VAColorUtility.themeTextIconColor

        /// update skip button title on the basic od chat transcript is enabled or not
        if self.chatTranscriptEnabled {
            self.skipButton.setTitle(LanguageManager.shared.localizedString(forKey: "Skip feedback"), for: .normal)
        } else {
            self.skipButton.setTitle(LanguageManager.shared.localizedString(forKey: "Close"), for: .normal)
        }
        self.skipButton.setTitleColor(VAColorUtility.themeTextIconColor, for: .normal)
        self.oneButton.tintColor = VAColorUtility.senderBubbleColor
        self.twoButton.tintColor = VAColorUtility.senderBubbleColor
        self.threeButton.tintColor = VAColorUtility.senderBubbleColor
        self.fourButton.tintColor = VAColorUtility.senderBubbleColor
        self.fiveButton.tintColor = VAColorUtility.senderBubbleColor
        self.sixButton.tintColor = VAColorUtility.senderBubbleColor
        self.sevenButton.tintColor = VAColorUtility.senderBubbleColor
        self.eightButton.tintColor = VAColorUtility.senderBubbleColor
        self.nineButton.tintColor = VAColorUtility.senderBubbleColor
        self.tenButton.tintColor = VAColorUtility.senderBubbleColor

        radioUnselectedImg = UIImage(named: "radio-unChecked", in: Bundle(for: NormalFeedbackVC.self), compatibleWith: nil)!.withRenderingMode(.alwaysTemplate)
        radioSelectedImg = UIImage(named: "radio-checked", in: Bundle(for: NormalFeedbackVC.self), compatibleWith: nil)!.withRenderingMode(.alwaysTemplate)

        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) { [self] in
            self.yesButton.setTitleColor(VAColorUtility.themeTextIconColor, for: .normal)
            self.noButton.setTitleColor(VAColorUtility.themeTextIconColor, for: .normal)
            self.yesButton.tintColor = VAColorUtility.senderBubbleColor
            self.noButton.tintColor = VAColorUtility.senderBubbleColor
            self.yesButton.setImage(self.radioUnselectedImg, for: .normal)
            self.noButton.setImage(radioUnselectedImg, for: .normal)
        }

        // update apperance of the submit button
        self.submitButton.layer.cornerRadius = 10
        self.submitButton.layer.borderWidth = 1
        self.submitButton.layer.borderColor = VAColorUtility.senderBubbleColor.cgColor
        self.submitButton.setTitleColor(VAColorUtility.senderBubbleColor, for: .normal)
        self.submitButton.isUserInteractionEnabled = false
        self.submitButton.backgroundColor = VAColorUtility.clear

        if npsSettings?.data?.count ?? 0 > 0 {
            // filter the nps data on the basic of current language
            let filter = npsSettings?.data?.filter({ obj in
                if obj.lang == VAConfigurations.language?.rawValue {
                    return true
                } else {
                    return false
                }
            })

            if filter?.count ?? 0 > 0 {
                self.ratingConfig = filter?.first
            } else {
                for index in 0..<(npsSettings?.data?.count ?? 0) {
                    let array = self.npsSettings?.data?[index].ratingWiseQuestions
                    if array?.count ?? 0 > 0 {
                        self.ratingConfig = self.npsSettings?.data?[index]
                    }
                }
            }

            // check for rating order i.e ascending or descending
            if self.ratingConfig?.ratingViewOrder == "desc"{
                self.ratingViewOrder = .descend
            } else {
                self.ratingViewOrder = .ascend
            }

            // show rating title text
            if let title = self.ratingConfig?.message {
                if title != "" {
                    self.showRatingsView(title: title.htmlToString)
                } else {
                    self.showRatingsView(title: LanguageManager.shared.localizedString(forKey: "Regarding the TELUS Virtual Assistant that just helped you, how would you rate its performance?"))
                }
            } else {
                self.showRatingsView(title: LanguageManager.shared.localizedString(forKey: "Regarding the TELUS Virtual Assistant that just helped you, how would you rate its performance?"))
            }
        } else {
            self.showRatingsView(title: LanguageManager.shared.localizedString(forKey: "Regarding the TELUS Virtual Assistant that just helped you, how would you rate its performance?"))
        }

        // check for rating scale i,e 1 to 10, 1 to 5 or none
        if self.ratingConfig?.ratingScale == "1 to 10"{
            self.ratingScale = 10
            self.sixToNineSV.isHidden = false
        } else if self.ratingConfig?.ratingScale == "1 to 5"{
            self.ratingScale = 5
            self.sixToNineSV.isHidden = true
        } else {
            self.ratingScale = 0
        }

        // check for rating type i.e numberic or emoji
        if let ratingType = self.ratingConfig?.ratingType {
            if ratingType == "numeric"{
                // if numeric rating type than show minimum or maximum rating lable
                self.updateMinMaxRating()
            } else {  }
        } else {  }

        self.feedTextView.delegate = self
        self.setupHeaderImageAndTitle()
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

    // MARK: - Update Minimum and Maximum Rating lable
    func updateMinMaxRating() {
        var ratingA: String = ""
        var ratingB: String = ""

        // get rating minimum label text
        if let min = ratingConfig?.minLabel {
            ratingA = min
        } else {
            ratingA = ""
        }

        // get rating maximum label text
        if let max = ratingConfig?.maxLabel {
            ratingB = max
        } else {
            ratingB = ""
        }

        // rating order
        switch self.ratingViewOrder {
        case .descend: // descending
            if self.ratingConfig?.ratingScale == "1 to 5"{ // scale "1 to 5"
                self.lblLowestRatingA.text = ratingB
                self.lblHighestRatingA.text = ratingA
                self.viewRatingA.isHidden = false
                self.viewRatingB.isHidden = true
            } else { // scale "1 to 10"
                self.lblLowestRatingA.text = ratingB
                self.lblHighestRatingA.text = ""
                self.lblLowestRatingB.text = ""
                self.lblHighestRatingB.text = ratingA
                self.viewRatingA.isHidden = false
                self.viewRatingB.isHidden = false
            }
        case .ascend: // ascending
            if self.ratingConfig?.ratingScale == "1 to 5"{ // scale "1 to 5"
                self.lblLowestRatingA.text = ratingA
                self.lblHighestRatingA.text = ratingB
                self.viewRatingA.isHidden = false
                self.viewRatingB.isHidden = true
            } else { // "1 to 10"
                self.lblLowestRatingA.text = ratingA
                self.lblHighestRatingA.text = ""
                self.lblLowestRatingB.text = ""
                self.lblHighestRatingB.text = ratingB
                self.viewRatingA.isHidden = false
                self.viewRatingB.isHidden = false
            }
        }
    }

    // MARK: - Show Rating View
    /// This function is used
    /// - Parameter title: String
    func showRatingsView(title: String) {
        self.ratingsTitleLbl.text = title
        self.ratingsTitleLbl.isHidden = false
        self.ratingsTitleLblHC.constant = 30
        self.ratingConfig?.ratingType == "emoji" ? self.setRatingViewAsEmoji():self.setRatingViewAsNumber()
    }
    // end

    // MARK: - Hide Rating View
    func hideRatingsView() {
        self.ratingsTitleLbl.isHidden = true
        self.ratingsTitleLblHC.constant = 0
    }
    // end

    // MARK: - Set Rating View for Emoji
    func setRatingViewAsEmoji() {
        // Set images according to rating order and rating scale
        switch self.ratingViewOrder {
        case .descend:
            if self.ratingConfig?.ratingScale == "1 to 5"{
                oneButton.setImage(UIImage(named: "emoji9", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                twoButton.setImage(UIImage(named: "emoji7", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                threeButton.setImage(UIImage(named: "emoji6", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                fourButton.setImage(UIImage(named: "emoji4", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                fiveButton.setImage(UIImage(named: "emoji2", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
            } else {
                oneButton.setImage(UIImage(named: "emoji10", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                twoButton.setImage(UIImage(named: "emoji9", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                threeButton.setImage(UIImage(named: "emoji8", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                fourButton.setImage(UIImage(named: "emoji7", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                fiveButton.setImage(UIImage(named: "emoji6", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                sixButton.setImage(UIImage(named: "emoji5", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                sevenButton.setImage(UIImage(named: "emoji4", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                eightButton.setImage(UIImage(named: "emoji3", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                nineButton.setImage(UIImage(named: "emoji2", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                tenButton.setImage(UIImage(named: "emoji1", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
            }
        case .ascend:
            if self.ratingConfig?.ratingScale == "1 to 5"{
                oneButton.setImage(UIImage(named: "emoji2", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                twoButton.setImage(UIImage(named: "emoji4", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                threeButton.setImage(UIImage(named: "emoji6", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                fourButton.setImage(UIImage(named: "emoji7", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                fiveButton.setImage(UIImage(named: "emoji9", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
            } else {
                oneButton.setImage(UIImage(named: "emoji1", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                twoButton.setImage(UIImage(named: "emoji2", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                threeButton.setImage(UIImage(named: "emoji3", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                fourButton.setImage(UIImage(named: "emoji4", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                fiveButton.setImage(UIImage(named: "emoji5", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                sixButton.setImage(UIImage(named: "emoji6", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                sevenButton.setImage(UIImage(named: "emoji7", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                eightButton.setImage(UIImage(named: "emoji8", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                nineButton.setImage(UIImage(named: "emoji9", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                tenButton.setImage(UIImage(named: "emoji10", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
            }
        }
    }
    // end

    // MARK: - Set Rating View for Numeric rating type
    func setRatingViewAsNumber() {
        // set button appearance
        oneButton.roundedShadowView(cornerRadius: 5, borderWidth: 0, borderColor: .clear)
        oneButton.backgroundColor = VAColorUtility.receiverBubbleColor
        oneButton.setTitleColor(VAColorUtility.senderBubbleColor, for: .normal)

        twoButton.roundedShadowView(cornerRadius: 5, borderWidth: 0, borderColor: .clear)
        twoButton.backgroundColor = VAColorUtility.receiverBubbleColor
        twoButton.setTitleColor(VAColorUtility.senderBubbleColor, for: .normal)

        threeButton.roundedShadowView(cornerRadius: 5, borderWidth: 0, borderColor: .clear)
        threeButton.backgroundColor = VAColorUtility.receiverBubbleColor
        threeButton.setTitleColor(VAColorUtility.senderBubbleColor, for: .normal)

        fourButton.roundedShadowView(cornerRadius: 5, borderWidth: 0, borderColor: .clear)
        fourButton.backgroundColor = VAColorUtility.receiverBubbleColor
        fourButton.setTitleColor(VAColorUtility.senderBubbleColor, for: .normal)

        fiveButton.roundedShadowView(cornerRadius: 5, borderWidth: 0, borderColor: .clear)
        fiveButton.backgroundColor = VAColorUtility.receiverBubbleColor
        fiveButton.setTitleColor(VAColorUtility.senderBubbleColor, for: .normal)

        sixButton.roundedShadowView(cornerRadius: 5, borderWidth: 0, borderColor: .clear)
        sixButton.backgroundColor = VAColorUtility.receiverBubbleColor
        sixButton.setTitleColor(VAColorUtility.senderBubbleColor, for: .normal)

        sevenButton.roundedShadowView(cornerRadius: 5, borderWidth: 0, borderColor: .clear)
        sevenButton.backgroundColor = VAColorUtility.receiverBubbleColor
        sevenButton.setTitleColor(VAColorUtility.senderBubbleColor, for: .normal)

        eightButton.roundedShadowView(cornerRadius: 5, borderWidth: 0, borderColor: .clear)
        eightButton.backgroundColor = VAColorUtility.receiverBubbleColor
        eightButton.setTitleColor(VAColorUtility.senderBubbleColor, for: .normal)

        nineButton.roundedShadowView(cornerRadius: 5, borderWidth: 0, borderColor: .clear)
        nineButton.backgroundColor = VAColorUtility.receiverBubbleColor
        nineButton.setTitleColor(VAColorUtility.senderBubbleColor, for: .normal)

        tenButton.roundedShadowView(cornerRadius: 5, borderWidth: 0, borderColor: .clear)
        tenButton.backgroundColor = VAColorUtility.receiverBubbleColor
        tenButton.setTitleColor(VAColorUtility.senderBubbleColor, for: .normal)

        // set button title according to rating scale and rating order
        switch self.ratingViewOrder {
        case .descend:
            if self.ratingConfig?.ratingScale == "1 to 5"{
                oneButton.setTitle(LanguageManager.shared.localizedString(forKey: "5"), for: .normal)
                twoButton.setTitle(LanguageManager.shared.localizedString(forKey: "4"), for: .normal)
                threeButton.setTitle(LanguageManager.shared.localizedString(forKey: "3"), for: .normal)
                fourButton.setTitle(LanguageManager.shared.localizedString(forKey: "2"), for: .normal)
                fiveButton.setTitle(LanguageManager.shared.localizedString(forKey: "1"), for: .normal)
            } else {
                oneButton.setTitle(LanguageManager.shared.localizedString(forKey: "10"), for: .normal)
                twoButton.setTitle(LanguageManager.shared.localizedString(forKey: "9"), for: .normal)
                threeButton.setTitle(LanguageManager.shared.localizedString(forKey: "8"), for: .normal)
                fourButton.setTitle(LanguageManager.shared.localizedString(forKey: "7"), for: .normal)
                fiveButton.setTitle(LanguageManager.shared.localizedString(forKey: "6"), for: .normal)
                sixButton.setTitle(LanguageManager.shared.localizedString(forKey: "5"), for: .normal)
                sevenButton.setTitle(LanguageManager.shared.localizedString(forKey: "4"), for: .normal)
                eightButton.setTitle(LanguageManager.shared.localizedString(forKey: "3"), for: .normal)
                nineButton.setTitle(LanguageManager.shared.localizedString(forKey: "2"), for: .normal)
                tenButton.setTitle(LanguageManager.shared.localizedString(forKey: "1"), for: .normal)
            }
        case .ascend:
            if self.ratingConfig?.ratingScale == "1 to 5"{
                oneButton.setTitle(LanguageManager.shared.localizedString(forKey: "1"), for: .normal)
                twoButton.setTitle(LanguageManager.shared.localizedString(forKey: "2"), for: .normal)
                threeButton.setTitle(LanguageManager.shared.localizedString(forKey: "3"), for: .normal)
                fourButton.setTitle(LanguageManager.shared.localizedString(forKey: "4"), for: .normal)
                fiveButton.setTitle(LanguageManager.shared.localizedString(forKey: "5"), for: .normal)
            } else {
                oneButton.setTitle(LanguageManager.shared.localizedString(forKey: "1"), for: .normal)
                twoButton.setTitle(LanguageManager.shared.localizedString(forKey: "2"), for: .normal)
                threeButton.setTitle(LanguageManager.shared.localizedString(forKey: "3"), for: .normal)
                fourButton.setTitle(LanguageManager.shared.localizedString(forKey: "4"), for: .normal)
                fiveButton.setTitle(LanguageManager.shared.localizedString(forKey: "5"), for: .normal)
                sixButton.setTitle(LanguageManager.shared.localizedString(forKey: "6"), for: .normal)
                sevenButton.setTitle(LanguageManager.shared.localizedString(forKey: "7"), for: .normal)
                eightButton.setTitle(LanguageManager.shared.localizedString(forKey: "8"), for: .normal)
                nineButton.setTitle(LanguageManager.shared.localizedString(forKey: "9"), for: .normal)
                tenButton.setTitle(LanguageManager.shared.localizedString(forKey: "10"), for: .normal)
            }

        }
    }
    // end

    // MARK: - Hide Answer Tag
    func hideAnswersTag() {
        self.answersTagTitleLabelTC.constant = 0
        self.answerTagsCollHightConst.constant = 0
        self.answersTagTitleLabel.text = ""
        self.answersTagTitleLabel.isHidden = true
        self.answerTagsCollView.isHidden = true
        self.answersTagContainer.isHidden = true
    }
    // end

    // MARK: - Show Answer Tag
    func showAnswersTag() {
        self.answerTagsCollHightConst.constant = 60
        self.answerTagsCollView.isHidden = false
        answersTagContainer.isHidden = false
        answersTagTitleLabel.isHidden = false
        answersTagTitleLabelTC.constant = 30
        self.answerTagsCollView.reloadData()
    }
    // end

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

    // MARK: - Hide Additional Feedback view
    func hideAdditionalFeedback() {
        // Hide
        feedTextViewContainer.isHidden = true
        // Height 0
        feedTextViewContainerHC.constant = 0
    }
    // end

    // MARK: - Show Additional Feedback view
    func showAdditionalFeedback() {
        feedTextView.layer.cornerRadius = 10
        feedTextView.layer.borderWidth = 1
        feedTextView.layer.borderColor = UIColor.lightGray.cgColor
        self.feedTextView.text = self.additionalFeedbackPlaceholder
        self.feedTextView.textColor = UIColor.lightGray
        // Text Content Inset from border
        self.feedTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        feedTextViewContainer.isHidden = false
        // Height fixed 160
        feedTextViewContainerHC.constant = 160
    }
    // end

    // MARK: - Did Load Answer Taqg
    ///  This function is used to get the answer tags for the selected rating value
    /// - Parameter tag: Int
    func didLoadAnswerTags(tag: Int) {
        var index: Int = tag
        switch self.ratingViewOrder {
        case .descend:
            if self.ratingConfig?.ratingScale == "1 to 5"{
                switch tag {
                case 4:
                    index = 0
                case 3:
                    index = 1
                case 2:
                    index = 2
                case 1:
                    index = 3
                case 0:
                    index = 4
                default:
                    print(tag)
                }
            } else {
                switch tag {
                case 9:
                    index = 0
                case 8:
                    index = 1
                case 7:
                    index = 2
                case 6:
                    index = 3
                case 5:
                    index = 4
                case 4:
                    index = 5
                case 3:
                    index = 6
                case 2:
                    index = 7
                case 1:
                    index = 8
                case 0:
                    index = 9
                default:
                    print(tag)
                }
            }
        case .ascend:
            print(tag)
        }

        // check for rating model
        if self.ratingConfig != nil {
            // check for answer tags
            if self.ratingConfig?.lang == VAConfigurations.language?.rawValue || self.ratingConfig?.lang == VAConfigurations.getCurrentLanguageCode() {
                if let questionArray = self.ratingConfig?.ratingWiseQuestions, questionArray.count > 0 {
                    if questionArray[index].answerTags?.count ?? 0 > 0 {
                        self.isAnswersTag = (questionArray[index].answerTags?.count ?? 0) > 0 ? true:false
                        self.ansArray = questionArray[index].answerTags ?? [String]()
                        questionArray[index].answerTags?.count ?? 0 > 0 ? showAnswersTag():hideAnswersTag()
                        self.answersTagTitleLabel.text = (questionArray[index].question ?? "")
                        self.answersTagTitleLabel.textColor = VAColorUtility.themeTextIconColor
                    } else {
                        self.hideAnswersTag()
                    }
                } else {
                    self.hideAnswersTag()
                }
            }
        } else { }
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
    
    func moveToChatTranscriptScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle(for: FeedbackSurveyVC.self))
        if let vcObj = storyboard.instantiateViewController(withIdentifier: "VAChatTranscriptVC") as? VAChatTranscriptVC {
            vcObj.textFontSize = self.textFontSize
            vcObj.fontName = self.fontName
            vcObj.configResulModel = self.configResulModel
            self.navigationController?.pushViewController(vcObj, animated: false)
        }
    }

    // MARK: - IBActions

    /// This function is used when user tap rating button
    @IBAction func emojiBtnAction(_ sender: UIButton) {
        // update submit button appearance
        self.submitButton.layer.cornerRadius = 10
        self.submitButton.layer.borderWidth = 1
        self.submitButton.layer.borderColor = VAColorUtility.senderBubbleColor.cgColor
        self.submitButton.backgroundColor = VAColorUtility.senderBubbleColor
        self.submitButton.setTitleColor(VAColorUtility.white, for: .normal)
        self.submitButton.isUserInteractionEnabled = true

        // check for feedback text
        if self.feedTextView.text != self.additionalFeedbackPlaceholder && self.feedTextView.text.count > 0 {
        } else {
            // reset feedTextView
            self.feedTextView.text = ""
            self.feedTextView.endEditing(true)
            // show or hide additional feedback
            self.npsSettings?.additionalFeedback ?? false ? (showAdditionalFeedback()):(hideAdditionalFeedback())
        }

        // show or hide radio button i.e YES or NO on the basic of issue resolved
        self.npsSettings?.issueResolved ?? false ? self.showRadio() : self.hideRadio()

        // set rating view on the basic of rating type i.e Number or Emoji
        self.ratingConfig?.ratingType == "emoji" ? self.setRatingViewAsEmoji() : self.setRatingViewAsNumber()

        // Update button color on the basic of rating type i.e Number or Emoji
        self.ratingConfig?.ratingType == "emoji" ? (sender.backgroundColor = .clear): (sender.backgroundColor = VAColorUtility.senderBubbleColor)

        // Update button title color on the basic of rating type i.e Number or Emoji
        self.ratingConfig?.ratingType == "emoji" ? (sender.setTitleColor(.clear, for: .normal)): (sender.setTitleColor(VAColorUtility.receiverBubbleColor, for: .normal))

        // load answer tag
        self.didLoadAnswerTags(tag: sender.tag)

        self.selectedAnswerTagArr.removeAll()

        self.selectedAnswerTagValueArr.removeAll()

        // Set images according to rating order and rating scale
        if self.ratingConfig?.ratingType == "emoji"{
            switch self.ratingViewOrder {
            case .descend:
                if self.ratingConfig?.ratingScale == "1 to 5"{
                    switch sender.tag {
                    case 0:
                        sender.setImage(UIImage(named: "emoji9-filled", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                    case 1:
                        sender.setImage(UIImage(named: "emoji7-filled", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                    case 2:
                        sender.setImage(UIImage(named: "emoji6-filled", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                    case 3:
                        sender.setImage(UIImage(named: "emoji4-filled", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                    case 4:
                        sender.setImage(UIImage(named: "emoji2-filled", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                    default:
                        print(sender.tag)
                    }
                } else {
                    switch sender.tag {
                    case 0:
                        sender.setImage(UIImage(named: "emoji10-filled", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                    case 1:
                        sender.setImage(UIImage(named: "emoji9-filled", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                    case 2:
                        sender.setImage(UIImage(named: "emoji8-filled", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                    case 3:
                        sender.setImage(UIImage(named: "emoji7-filled", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                    case 4:
                        sender.setImage(UIImage(named: "emoji6-filled", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                    case 5:
                        sender.setImage(UIImage(named: "emoji5-filled", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                    case 6:
                        sender.setImage(UIImage(named: "emoji4-filled", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                    case 7:
                        sender.setImage(UIImage(named: "emoji3-filled", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                    case 8:
                        sender.setImage(UIImage(named: "emoji2-filled", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                    case 9:
                        sender.setImage(UIImage(named: "emoji1-filled", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                    default:
                        print(sender.tag)
                    }
                }
            case .ascend:
                if self.ratingConfig?.ratingScale == "1 to 5"{
                    switch sender.tag {
                    case 0:
                        sender.setImage(UIImage(named: "emoji2-filled", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                    case 1:
                        sender.setImage(UIImage(named: "emoji4-filled", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                    case 2:
                        sender.setImage(UIImage(named: "emoji6-filled", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                    case 3:
                        sender.setImage(UIImage(named: "emoji7-filled", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                    case 4:
                        sender.setImage(UIImage(named: "emoji9-filled", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                    default:
                        print(sender.tag)
                    }
                } else {
                    switch sender.tag {
                    case 0:
                        sender.setImage(UIImage(named: "emoji1-filled", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                    case 1:
                        sender.setImage(UIImage(named: "emoji2-filled", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                    case 2:
                        sender.setImage(UIImage(named: "emoji3-filled", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                    case 3:
                        sender.setImage(UIImage(named: "emoji4-filled", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                    case 4:
                        sender.setImage(UIImage(named: "emoji5-filled", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                    case 5:
                        sender.setImage(UIImage(named: "emoji6-filled", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                    case 6:
                        sender.setImage(UIImage(named: "emoji7-filled", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                    case 7:
                        sender.setImage(UIImage(named: "emoji8-filled", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                    case 8:
                        sender.setImage(UIImage(named: "emoji9-filled", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                    case 9:
                        sender.setImage(UIImage(named: "emoji10-filled", in: Bundle(for: FeedbackSurveyVC.self), with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                    default:
                        print(sender.tag)
                    }
                }
            }
        }

        // get score
        switch self.ratingViewOrder {
        case .descend:
            if self.ratingConfig?.ratingScale == "1 to 5"{
                switch sender.tag {
                case 0:
                    score = 5*2
                case 1:
                    score = 4*2
                case 2:
                    score = 3*2
                case 3:
                    score = 2*2
                case 4:
                    score = 1*2
                default:
                    print(sender.tag)
                }
            } else {
                switch sender.tag {
                case 0:
                    self.ratingConfig?.ratingScale == "1 to 10" ?( score = 10 ):( score = 1*2)
                case 1:
                    self.ratingConfig?.ratingScale == "1 to 10" ?( score = 9 ):( score = 2*2)
                case 2:
                    self.ratingConfig?.ratingScale == "1 to 10" ?( score = 8 ):( score = 3*2)
                case 3:
                    self.ratingConfig?.ratingScale == "1 to 10" ?( score = 7 ):( score = 4*2)
                case 4:
                    self.ratingConfig?.ratingScale == "1 to 10" ?( score = 6 ):( score = 5*2)
                case 5:
                    score = 5
                case 6:
                    score = 4
                case 7:
                    score = 3
                case 8:
                    score = 2
                case 9:
                    score = 1
                default:
                    print(sender.tag)
                }
            }
        case .ascend:
            switch sender.tag {
            case 0:
                self.ratingConfig?.ratingScale == "1 to 10" ?( score = 1 ):( score = 1*2)
            case 1:
                self.ratingConfig?.ratingScale == "1 to 10" ?( score = 2 ):( score = 2*2)
            case 2:
                self.ratingConfig?.ratingScale == "1 to 10" ?( score = 3 ):( score = 3*2)
            case 3:
                self.ratingConfig?.ratingScale == "1 to 10" ?( score = 4 ):( score = 4*2)
            case 4:
                self.ratingConfig?.ratingScale == "1 to 10" ?( score = 5 ):( score = 5*2)
            case 5:
                score = 6
            case 6:
                score = 7
            case 7:
                score = 8
            case 8:
                score = 9
            case 9:
                score = 10
            default:
                print(sender.tag)
            }
        }

        switch self.ratingViewOrder {
        case .descend:
            if self.ratingConfig?.ratingScale == "1 to 10"{
                switch sender.tag {
                case 0:
                    self.ratingConfig?.ratingScale == "1 to 10" ?( score = 10 ):( score = 1*2)
                case 1:
                    self.ratingConfig?.ratingScale == "1 to 10" ?( score = 9 ):( score = 2*2)
                case 2:
                    self.ratingConfig?.ratingScale == "1 to 10" ?( score = 8 ):( score = 3*2)
                case 3:
                    self.ratingConfig?.ratingScale == "1 to 10" ?( score = 7 ):( score = 4*2)
                case 4:
                    self.ratingConfig?.ratingScale == "1 to 10" ?( score = 6 ):( score = 5*2)
                case 5:
                    score = 5
                case 6:
                    score = 4
                case 7:
                    score = 3
                case 8:
                    score = 2
                case 9:
                    score = 1
                default:
                    print(sender.tag)
                }
            } else if self.ratingConfig?.ratingScale == "1 to 5"{
                switch sender.tag {
                case 0:
                    score = 5*2
                case 1:
                    score = 4*2
                case 2:
                    score = 3*2
                case 3:
                    score = 2*2
                case 4:
                    score = 1*2
                default:
                    print(sender.tag)
                }
            } else {
                switch sender.tag {
                case 0:
                    self.ratingConfig?.ratingScale == "1 to 10" ?( score = 10 ):( score = 1*2)
                case 1:
                    self.ratingConfig?.ratingScale == "1 to 10" ?( score = 9 ):( score = 2*2)
                case 2:
                    self.ratingConfig?.ratingScale == "1 to 10" ?( score = 8 ):( score = 3*2)
                case 3:
                    self.ratingConfig?.ratingScale == "1 to 10" ?( score = 7 ):( score = 4*2)
                case 4:
                    self.ratingConfig?.ratingScale == "1 to 10" ?( score = 6 ):( score = 5*2)
                case 5:
                    score = 5
                case 6:
                    score = 4
                case 7:
                    score = 3
                case 8:
                    score = 2
                case 9:
                    score = 1
                default:
                    print(sender.tag)
                }
            }
        case .ascend:
            switch sender.tag {
            case 0:
                self.ratingConfig?.ratingScale == "1 to 10" ?( score = 1 ):( score = 1*2)
            case 1:
                self.ratingConfig?.ratingScale == "1 to 10" ?( score = 2 ):( score = 2*2)
            case 2:
                self.ratingConfig?.ratingScale == "1 to 10" ?( score = 3 ):( score = 3*2)
            case 3:
                self.ratingConfig?.ratingScale == "1 to 10" ?( score = 4 ):( score = 4*2)
            case 4:
                self.ratingConfig?.ratingScale == "1 to 10" ?( score = 5 ):( score = 5*2)
            case 5:
                score = 6
            case 6:
                score = 7
            case 7:
                score = 8
            case 8:
                score = 9
            case 9:
                score = 10
            default:
                print(sender.tag)
            }
        }
    }
    // end

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

    /// This function is used when user tap submit button
    @IBAction func submitBtnAction(_ sender: Any) {
        var strIssueResolved: String = ""

        self.isIssueResolved == nil ? (strIssueResolved = "") : (self.isIssueResolved == true ? (strIssueResolved = "true"): ( strIssueResolved = "false"))

        var feedbackMsg: String = ""
        if self.feedTextView.text == self.additionalFeedbackPlaceholder {
            feedbackMsg = ""
        } else {
            feedbackMsg = self.feedTextView.text
        }

        // API call to submit feedback data
        APIManager.sharedInstance.submitNPSSurveyFeedback(reason: self.selectedAnswerTagValueArr, score: self.score, feedback: feedbackMsg, issueResolved: strIssueResolved) { (resultStr) in
            DispatchQueue.main.async {
                // Disable IQKeyboardManager
                IQKeyboardManager.shared.enable = false
                // Show alert
                UIAlertController.openAlertWithOk(LanguageManager.shared.localizedString(forKey: "Message!"), 
                                                  resultStr,
                                                  LanguageManager.shared.localizedString(forKey: "OK"),
                                                  view: self) {
                    // if chatTranscript is enabled than open VAChatTranscriptVC controller else send notification on previous UIViewController
                    if self.chatTranscriptEnabled == true {
                        // Open VAChatTranscriptVC
                        self.moveToChatTranscriptScreen()
                    } else {
                        self.closeChatbot()
                    }
                }
            }
        }
    }

    /// This function is used when user tap close button
    @IBAction func closeBtnAction(_ sender: Any) {
        // Disable IQKeyboardManager
        IQKeyboardManager.shared.enable = false
        // if chatTranscript is enabled than open VAChatTranscriptVC controller else send notification on previous UIViewController
        if self.chatTranscriptEnabled == true {
            self.moveToChatTranscriptScreen()
        } else {
            self.closeChatbot()
        }
    }
}
// end

// MARK: - FeedbackSurveyVC extension of UICollectionView
/// UICollection view used for Answer Tags
extension FeedbackSurveyVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.ansArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AnsTagsCollectionViewCell", for: indexPath) as? AnsTagsCollectionViewCell {
            self.selectedAnswerTagArr.contains(indexPath) ? (cell.container.backgroundColor = VAColorUtility.senderBubbleColor):(cell.container.backgroundColor = .clear)
            self.selectedAnswerTagArr.contains(indexPath) ? (cell.name.textColor = VAColorUtility.receiverBubbleColor):(cell.name.textColor = VAColorUtility.themeTextIconColor)
            cell.name.text = "\(ansArray[indexPath.item])"
            cell.name.font = UIFont(name: fontName, size: textFontSize)
            cell.container.borderColor = VAColorUtility.receiverBubbleColor
            cell.container.layer.borderWidth = 1
            return cell
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let selectedItem = collectionView.cellForItem(at: indexPath) as? AnsTagsCollectionViewCell {
            self.selectedTagIndexPath = indexPath
            if selectedAnswerTagArr.contains(indexPath) {
                selectedAnswerTagArr.remove(at: selectedAnswerTagArr.firstIndex(of: indexPath) ?? -1)
                selectedAnswerTagValueArr.remove(at: selectedAnswerTagValueArr.firstIndex(of: selectedItem.name.text ?? "") ?? -1)
            } else {
                selectedAnswerTagArr.append(indexPath)
                selectedAnswerTagValueArr.append(selectedItem.name.text ?? "")
            }
            // reload collection view
            self.answerTagsCollView.reloadData()
        }
    }
}
// end

// MARK: - FeedbackSurveyVC extension of UITextViewDelegate
extension FeedbackSurveyVC: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)

        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }

        // show character's count
        if newText.count <= self.maxCharacterLimit {
            self.lblFeedbackCharLimit.text = "\(newText.count)/\(self.maxCharacterLimit)"
        }
        let maxLength =  self.maxCharacterLimit

        // disable typing when maxLenght reached
        return newText.count <= maxLength
    }

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        // remove placeholder text
        if textView.text == self.additionalFeedbackPlaceholder {
            textView.text = ""
            self.feedTextView.textColor = VAColorUtility.themeTextIconColor
        }
        return true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        // show placeholder text when uitextview is empty
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            textView.text = self.additionalFeedbackPlaceholder
            self.feedTextView.textColor = UIColor.lightGray
        }
    }
}
// end
