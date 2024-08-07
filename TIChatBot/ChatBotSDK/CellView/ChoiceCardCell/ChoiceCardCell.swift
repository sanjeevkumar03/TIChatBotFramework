// ChoiceCardCell.swift
// Copyright © 2021 Telus International. All rights reserved.

import UIKit
import SDWebImage

// MARK: Protocol definition
protocol ChoiceCardCellDelegate: AnyObject {
    func didTapConfirmButton(response: [Choice], indexPath: IndexPath)
    func didTapMoreOptionsButton(response: [Choice], indexPath: IndexPath, isMultiSelect: Bool )
    func didTapSkipButton(indexPath: IndexPath)
}

class ChoiceCardCell: UITableViewCell {

    // MARK: Outlet declaration
    @IBOutlet weak var avatarViewWidth: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var seperatorTitleView: UIView!
    @IBOutlet weak var seperatorConfirmView: UIView!
    @IBOutlet weak var botImgBGView: UIView!
    @IBOutlet weak var botImgView: UIImageView!
    @IBOutlet weak var chatBubbleImgView: UIImageView!
    @IBOutlet weak var containerViewWidth: NSLayoutConstraint!
    @IBOutlet weak var skipTitleLabel: UILabel!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var skipView: UIView!
    @IBOutlet weak var optionsTable: UITableView! {
        didSet {
            self.optionsTable.delegate = self
            self.optionsTable.dataSource = self
            self.optionsTable.register(UINib(nibName: ChoiceCardOptionCell.nibName, bundle: Bundle(for: ChoiceCardCell.self)), forCellReuseIdentifier: ChoiceCardOptionCell.identifier)
        }
    }
    @IBOutlet weak var optionsTableHeight: NSLayoutConstraint!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var moreOptionsView: UIView!
    @IBOutlet weak var moreOptionsButton: UIButton!
    @IBOutlet weak var confirmView: UIView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var skipButtonViewHeight: NSLayoutConstraint!
    @IBOutlet weak var skipButtonViewTop: NSLayoutConstraint!
    @IBOutlet weak var skipButtonViewBottom: NSLayoutConstraint!

    // MARK: Property declaration
    static let nibName = "ChoiceCardCell"
    static let identifier = "ChoiceCardCell"
    var arrayOfOptions: [Choice] = []
    var isMultiSelect: Bool = false
    var indexPath: IndexPath?
    weak var delegate: ChoiceCardCellDelegate?
    var configurationModal: VAConfigurationModel?
    var isShowBotImage: Bool = true
    var optionLimit: Int = 3
    var allowSkipButton: Bool = false
    var isMultiOpsTapped: Bool = false
    let confirmStaticText = LanguageManager.shared.localizedString(forKey: "Confirm")
    var fontName: String = ""
    var textFontSize: Double = 0.0
    var optionsRowHeight: CGFloat = 45.0

    override func awakeFromNib() {
        super.awakeFromNib()
        self.confirmView.isHidden = true
        self.moreOptionsView.isHidden = true
        self.skipButton.setTitle("", for: .normal)
        self.optionsTable.addObserver(self, forKeyPath: "contentSize", options: [], context: nil)
    }
    
    // MARK: Observer

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // print("Table Height: \(self.optionsTable.contentSize.height)")
        // self.optionsTableHeight.constant = self.optionsTable.contentSize.height
    }

    // MARK: Custom methods

    func setCardUI() {
        if configurationModal?.result?.enableAvatar ?? true {
            if isShowBotImage {
                self.setBotImage()
                botImgBGView.isHidden = false
                chatBubbleImgView.image = ChatBubble.createChatBubble(isBotMsg: true)
            } else {
                botImgBGView.isHidden = true
                chatBubbleImgView.image = ChatBubble.createRoundedChatBubble()
            }
        } else {
            avatarViewWidth.constant = 0
            botImgBGView.isHidden = true
            chatBubbleImgView.image = ChatBubble.createRoundedChatBubble()
        }
    }

    /// Used to configure image card
    /// - Parameter imageURL: It accepts image url string.
    func configure(model: MultiOps?, isMultiSelect: Bool, indexPath: IndexPath, isMultiOpsTapped: Bool, allowSkip: Bool) {
        self.optionLimit = (model?.optionsLimit == nil || model?.optionsLimit == 0) ? 3 : model?.optionsLimit ?? 3
        self.isMultiOpsTapped = isMultiOpsTapped
        self.allowSkipButton = allowSkip
        if model?.options.count ?? 0 > 0, self.allowSkipButton == true {
            self.skipButtonViewHeight.constant = 40
            self.skipButton.isHidden = false
            self.skipTitleLabel.isHidden = false

            let attributedStr: NSMutableAttributedString = model?.options[0].attributedTitle ??  NSMutableAttributedString(string: "")
            attributedStr.addAttribute(.font, value: UIFont(name: fontName, size: textFontSize)!, range: NSRange(location: 0, length: attributedStr.length))
            self.skipTitleLabel.attributedText = attributedStr
            self.titleLabel.textColor = VAColorUtility.receiverBubbleTextIconColor
            self.skipButtonViewTop.constant = 10
            self.skipButtonViewBottom.constant = 5
            self.skipView.layer.cornerRadius = 8
            self.skipView.layer.borderWidth = 1
            self.skipView.layer.borderColor = VAColorUtility.buttonColor.cgColor
            self.skipTitleLabel.textColor = VAColorUtility.buttonColor
        } else {
            self.skipButtonViewHeight.constant = 0
            self.skipButton.isHidden = true
            self.skipTitleLabel.isHidden = true
            self.skipButtonViewTop.constant = 0
            self.skipButtonViewBottom.constant = 0
        }
        self.setCardUI()
        self.indexPath = indexPath
        self.isMultiSelect = isMultiSelect
        self.containerViewWidth.constant = UIDevice.current.userInterfaceIdiom == .phone ? (UIScreen.main.bounds.width*0.7) : (UIScreen.main.bounds.width*0.4)

        let attributedStr: NSMutableAttributedString = model?.attributedTitle ??  NSMutableAttributedString(string: "")
        attributedStr.addAttribute(.font, value: UIFont(name: fontName, size: textFontSize)!, range: NSRange(location: 0, length: attributedStr.length))
        self.titleLabel.attributedText = attributedStr
        /*if isHTMLText(completeText: model?.text ?? ""){
         let completeAttributedText = getAttributedTextFromHTML(text: model?.text ?? "")
         self.titleLabel.attributedText = completeAttributedText
         }else{
         self.titleLabel.text = model?.text ?? ""
         }*/
        self.arrayOfOptions = model?.choices ?? []
        self.moreOptionsView.backgroundColor = VAColorUtility.receiverBubbleColor
        self.titleView.backgroundColor = VAColorUtility.receiverBubbleColor
        self.titleLabel.textColor = VAColorUtility.receiverBubbleTextIconColor
        self.confirmButton.setTitleColor(VAColorUtility.defaultThemeTextIconColor, for: .normal)
        self.moreOptionsButton.setTitleColor(VAColorUtility.receiverBubbleTextIconColor, for: .normal)
        self.seperatorTitleView.backgroundColor = VAColorUtility.defaultThemeTextIconColor
        self.seperatorConfirmView.backgroundColor = VAColorUtility.defaultThemeTextIconColor

        self.confirmButton.layer.cornerRadius = 4
        self.confirmButton.backgroundColor = VAColorUtility.receiverBubbleColor
        self.confirmView.backgroundColor = VAColorUtility.defaultThemeTextIconColor
        DispatchQueue.main.async { [self] in
            self.moreOptionsButton.setTitle(LanguageManager.shared.localizedString(forKey: "More Options"), for: .normal)
            self.moreOptionsButton.titleLabel?.font = UIFont(name: self.fontName, size: self.textFontSize)
            self.skipButton.titleLabel?.font = UIFont(name: self.fontName, size: self.textFontSize)
        }

        if isMultiOpsTapped {
            UIView.performWithoutAnimation {
                self.optionsTableHeight.constant = 0
                self.confirmView.isHidden = true
                self.moreOptionsView.isHidden = true
                self.seperatorTitleView.isHidden = true
            }
            self.arrayOfOptions = []
        } else {
            self.seperatorTitleView.isHidden = false
            if self.arrayOfOptions.count > self.optionLimit {
                if self.isMultiSelect {
                    self.confirmView.isHidden = false
                } else {
                    self.confirmView.isHidden = true
                }
                self.moreOptionsView.isHidden = false
                self.updateConfirmButton()
            } else if isMultiSelect && self.arrayOfOptions.count > 0 && self.arrayOfOptions.count <= self.optionLimit {
                self.moreOptionsView.isHidden = true
                self.confirmView.isHidden = false
                self.updateConfirmButton()
            } else {
                self.confirmView.isHidden = true
                self.moreOptionsView.isHidden = true
            }
        }

        if isMultiOpsTapped {
            self.chatBubbleImgView.tintColor = VAColorUtility.receiverBubbleColor
            self.titleView.backgroundColor = VAColorUtility.clear
        } else {
            self.chatBubbleImgView.tintColor = VAColorUtility.receiverBubbleColor
            self.titleView.backgroundColor = VAColorUtility.receiverBubbleColor
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+0.01) {
            self.optionsTable.reloadData()
        }
        self.stackView.layer.cornerRadius = 4
        if self.isMultiOpsTapped {
            self.optionsTableHeight.constant = 0
        } else {
            if self.arrayOfOptions.count > self.optionLimit {
                self.optionsTableHeight.constant = CGFloat(self.optionLimit * Int(optionsRowHeight))
            } else {
                self.optionsTableHeight.constant = CGFloat(self.arrayOfOptions.count * Int(optionsRowHeight))
            }
        }
    }
    private func getArraySelectedItem() -> [Choice] {
        if self.arrayOfOptions.count > 0 {
            let filterArray = self.arrayOfOptions.filter { obj in
                if obj.isSelected == true {
                    return true
                } else {
                    return false
                }
            }
            return filterArray
        } else {
            return []
        }
    }
    private func updateConfirmButton() {
        let filterArray = self.getArraySelectedItem()
        if filterArray.count > 0 {
            self.confirmButton.setTitleColor(VAColorUtility.receiverBubbleTextIconColor, for: .normal)
            self.confirmButton.setTitle("\(self.confirmStaticText) (\(filterArray.count))", for: .normal)
        } else {
            self.confirmButton.setTitleColor(VAColorUtility.defaultThemeTextIconColor, for: .normal)
            self.confirmButton.setTitle("\(self.confirmStaticText) (0)", for: .normal)
        }
        self.confirmButton.titleLabel?.font = UIFont(name: fontName, size: textFontSize)
    }
    func setBotImage() {
        if let url = URL(string: self.configurationModal?.result?.avatar ?? "") {
            botImgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            botImgView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholderImage", in: Bundle(for: TextCardCell.self), with: nil))
        } else {
            self.botImgView.image = UIImage(named: "botDefaultIcon", in: Bundle(for: TextCardCell.self), with: nil)?.withRenderingMode(.alwaysTemplate)
            self.botImgView.tintColor = VAColorUtility.senderBubbleColor
        }
    }

    @IBAction func confirmTapped(_ sender: UIButton) {
        let filterArray = self.getArraySelectedItem()
        if filterArray.count > 0 {
            self.delegate?.didTapConfirmButton(response: self.arrayOfOptions, indexPath: self.indexPath!)
        } else {}
    }
    @IBAction func moreOptionsTapped(_ sender: UIButton) {
        self.delegate?.didTapMoreOptionsButton(response: self.arrayOfOptions, indexPath: self.indexPath!, isMultiSelect: self.isMultiSelect)
    }
    @IBAction func skipButtonTapped(_ sender: UIButton) {
        self.delegate?.didTapSkipButton(indexPath: self.indexPath!)
    }
}

// MARK: UITableViewDelegate & UITableViewDataSource

extension ChoiceCardCell: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isMultiOpsTapped {
            return 0
        } else {
            if self.arrayOfOptions.count > self.optionLimit {
                return self.optionLimit
            } else {
                return self.arrayOfOptions.count
            }
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: ChoiceCardOptionCell.identifier, for: indexPath) as? ChoiceCardOptionCell {
            cell.configure(title: self.arrayOfOptions[indexPath.row].label, isMultiSelect: self.isMultiSelect, isSelect: self.arrayOfOptions[indexPath.row].isSelected)
            cell.checkboxButton.tag = indexPath.row
            cell.checkboxButton.addTarget(self, action: #selector(checkboxTapped(sender:)), for: .touchUpInside)
            cell.titleLabel.font = UIFont(name: fontName, size: textFontSize-1.5)
            if self.arrayOfOptions.count > optionLimit - 1 {
                cell.seperatorView.isHidden = false
            } else {
                cell.seperatorView.isHidden = false
            }
            return cell
        } else {
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.updateChoiceArrayOnSelection(index: indexPath.row)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return optionsRowHeight
    }

    @objc func checkboxTapped(sender: UIButton) {
        self.updateChoiceArrayOnSelection(index: sender.tag)
    }

    private func updateChoiceArrayOnSelection(index: Int) {
        var choice: Choice = self.arrayOfOptions[index]
        if choice.isSelected {
            choice.isSelected = false
        } else {
            choice.isSelected = true
        }
        self.arrayOfOptions[index] = choice
        if self.isMultiSelect {
            self.updateConfirmButton()
        } else {
            self.delegate?.didTapConfirmButton(response: self.arrayOfOptions, indexPath: self.indexPath!)
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+0.01) {
            self.optionsTable.reloadData()
        }
    }
}
