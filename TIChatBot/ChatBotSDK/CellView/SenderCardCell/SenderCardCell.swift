// SenderCardCell.swift
// Copyright © 2021 Telus International. All rights reserved.

import UIKit

class SenderCardCell: UITableViewCell {

    // MARK: Outlet Declaration
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var chatBubbleImgView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var msgContentViewLeading: NSLayoutConstraint!
    @IBOutlet weak var msgContentViewTrailing: NSLayoutConstraint!
    @IBOutlet weak var containerViewWidth: NSLayoutConstraint!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dateLabelTop: NSLayoutConstraint!
    @IBOutlet weak var dateLabelBottom: NSLayoutConstraint!
    @IBOutlet weak var avatarViewWidth: NSLayoutConstraint!
    @IBOutlet weak var avatarView: UIView!
    @IBOutlet weak var replyMessageButton: UIButton!
    @IBOutlet weak var replyBGView: UIView!
    @IBOutlet weak var replyView: UIView!
    @IBOutlet weak var replyLabel: UILabel!
    @IBOutlet weak var replyButton: UIButton!

    // MARK: Property Declaration
    static let nibName = "SenderCardCell"
    static let identifier = "SenderCardCell"
    var bubbleColor: UIColor = .white
    var completeText: String = ""
    var completeAttributedText: NSAttributedString?
    var configIntegration: VAConfigIntegration?
    var configurationModal: VAConfigurationModel?
    var repliedMessageDict: [String: Any] = [:]
    weak var delegate: AgentTextCardCellDelegate?
    var indexPath: IndexPath!
    var fontName: String = ""
    var textFontSize: Double = 0.0
    var dateFontSize: Double = 0.0
    var isChatToolChatClosed: Bool = false

    // MARK: Cell lifecycle methods
    override func awakeFromNib() {
        super.awakeFromNib()
        chatBubbleImgView.tintColor = bubbleColor
        containerViewWidth.constant = ChatBubble.getChatBubbleWidth()
        self.titleLabel.textColor = .white

        replyMessageButton.setTitle("", for: .normal)
        replyLabel.text = ""
        replyButton.isHidden = true
        /*replyButton.setTitle("", for: .normal)
         if VAConfigurations.isChatTool {
            self.replyButton.isHidden = false
        } else {
            self.replyButton.isHidden = true
        }
        self.replyButton.borderColor = VAColorUtility.themeColor
        self.replyButton.backgroundColor = VAColorUtility.senderBubbleColor
        self.replyButton.tintColor = VAColorUtility.themeColor
        self.replyButton.imageView?.layer.transform = CATransform3DMakeScale(0.8, 0.8, 0.8)*/
    }

    // MARK: Custom methods
    func configure(indexPath: IndexPath, sentiment: Int?, configIntegration: VAConfigIntegration?, date: Date, masked: Bool?, repliedMessageDict: [String: Any]) {
        self.titleLabel.font = UIFont(name: fontName, size: textFontSize)
        self.dateLabel.font  = UIFont(name: fontName, size: dateFontSize)
        self.indexPath = indexPath
        self.repliedMessageDict = repliedMessageDict
        self.setCardUI()
        self.configIntegration = configIntegration
        self.chatBubbleImgView.tintColor = VAColorUtility.senderBubbleColor
        self.dateLabel.textColor = VAColorUtility.themeTextIconColor
        self.titleLabel.textColor = VAColorUtility.senderBubbleTextIconColor
        var senderText = completeText
        if VAConfigurations.isChatTool {
            titleLabel.text = senderText
        } else {
            senderText = masked == false ? completeText : self.checkForTranscript(configIntegration: configIntegration)
            titleLabel.text = senderText
        }
        if senderText.count > 10 {
            titleLabel.textAlignment = .right
        } else {
            titleLabel.textAlignment = .center
        }
        self.dateLabel.text = self.getCurrentTime(date: date)
        self.imgView.image = self.getSenderImage(sentiment: sentiment)
        self.imgView.tintColor = VAColorUtility.themeTextIconColor
        self.replyLabel.textColor = VAColorUtility.receiverBubbleTextIconColor
        if self.repliedMessageDict.count > 0 {
            if let msg = self.repliedMessageDict["msg"] as? String {
                self.replyLabel.text = msg
                self.replyBGView.isHidden = false
            } else {
                self.replyLabel.text = ""
                self.replyBGView.isHidden = true
            }
        } else {
            self.replyLabel.text = ""
            self.replyBGView.isHidden = true
        }
    }

    func setCardUI() {
        if configurationModal?.result?.enableAvatar ?? true {
            avatarView.isHidden = false
            chatBubbleImgView.image = ChatBubble.createChatBubble(isBotMsg: false)
        } else {
            avatarViewWidth.constant = 0
            msgContentViewLeading.constant = 8
            msgContentViewTrailing.constant = -15
            avatarView.isHidden = true
            chatBubbleImgView.image = ChatBubble.createRoundedChatBubble()
        }

    }
    func checkForTranscript(configIntegration: VAConfigIntegration?) -> String {
        if let array = configIntegration?.redaction, array.count > 0 {
            var isRegexMatched: Bool = false
            var modifiedString: String = ""
            for index in 0..<array.count {
                let model = array[index]
                if model.active != nil && model.active == true {
                    if let regex = model.regex {
                        isRegexMatched = completeText.matches(regex)
                        if completeText.contains("•") {
                            return "●●●●●●●●●●"/// this is to show user 10 dots whether user types 1 character or 100 chars.
                            ///For security so that user cant guess how many characters user has typed.
                        }
                        if isRegexMatched {
                            modifiedString = String(repeating: "*", count: completeText.count)
                            break
                        }
                    }
                }
            }
            return isRegexMatched ? modifiedString : completeText
        }
        return completeText
    }

    private func getSenderImage(sentiment: Int?) -> UIImage {
        if sentiment == 1 {
            return UIImage(named: "emoji7", in: Bundle(for: VAChatViewController.self), with: nil)!
        } else if sentiment == -1 {
            return UIImage(named: "emoji3", in: Bundle(for: VAChatViewController.self), with: nil)!
        } else {
            return UIImage(named: "emoji6", in: Bundle(for: VAChatViewController.self), with: nil)!
        }
    }

    func getLabelText() -> String {
        return completeText
    }

    func getAttributedLabelText() -> NSAttributedString {
        return completeAttributedText!
    }

    func getCurrentTime(date: Date) -> String {
        let currentDateTime = date
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy, h:mm:ss a"
        return formatter.string(from: currentDateTime)
    }

    @IBAction func replyMessageTapped(_ sender: UIButton) {
        delegate?.didTapOnReply(repliedMessageDict: self.repliedMessageDict, indexPath: self.indexPath)
    }

    @IBAction func replyButtonTapped(_ sender: UIButton) {
        delegate?.didTapOnReplyButton(indexPath: self.indexPath)
    }
}

extension String {
    mutating func removingRegexMatches(pattern: String, replaceWith: String = "*****") {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let range = NSRange(location: 0, length: count)
            self = regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: replaceWith)
        } catch { return }
    }
}
