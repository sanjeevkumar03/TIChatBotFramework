// AgentTextCardCell.swift
// Copyright © 2021 Telus International. All rights reserved.

import UIKit
import SDWebImage

// MARK: Protocol definition
protocol AgentTextCardCellDelegate: AnyObject {
    func didTapReadMoreAgentText(indexPath: IndexPath)
    func didTapOnReply(repliedMessageDict: [String: Any], indexPath: IndexPath)
    func didTapOnReplyButton(indexPath: IndexPath)
}

class AgentTextCardCell: UITableViewCell {
    // MARK: Outlet Declaration
    @IBOutlet weak var avatarViewWidth: NSLayoutConstraint!
    @IBOutlet weak var botImgBGView: UIView!
    @IBOutlet weak var botImgView: UIImageView!
    @IBOutlet weak var chatBubbleImgView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var readMoreContainerView: UIView!
    @IBOutlet weak var readMoreButton: UIButton!
    @IBOutlet weak var readMoreLabel: UILabel!
    @IBOutlet weak var containerViewWidth: NSLayoutConstraint!
    @IBOutlet weak var cardViewTrailingEqual: NSLayoutConstraint!
    @IBOutlet weak var cardViewTrailingGreaterThan: NSLayoutConstraint!
    @IBOutlet weak var replyMessageButton: UIButton!
    @IBOutlet weak var replyBGView: UIView!
    @IBOutlet weak var replyView: UIView!
    @IBOutlet weak var replyLabel: UILabel!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    // MARK: Property Declaration
    static let nibName = "AgentTextCardCell"
    static let identifier = "AgentTextCardCell"
    var isCellExpanded: Bool = false
    var completeText: String = ""
    var completeAttributedText: NSMutableAttributedString?
    var configurationModal: VAConfigurationModel?
    var msgDate: Date? = nil
    weak var delegate: AgentTextCardCellDelegate?
    var repliedMessageDict: [String: Any] = [:]
    var indexPath: IndexPath!
    var fontName: String = ""
    var textFontSize: Double = 0.0
    var isDoNotRespond: Bool = false
    var isChatToolChatClosed: Bool = false
    var dateFontSize: Double = 0.0
    
    // MARK: Cell lifecycle methods
    override func awakeFromNib() {
        super.awakeFromNib()
        containerViewWidth.constant = ChatBubble.getChatBubbleWidth()
        readMoreButton.setTitle("", for: .normal)
        replyMessageButton.setTitle("", for: .normal)
        replyLabel.text = ""
        self.replyButton.isHidden = true
        /*replyButton.setTitle("", for: .normal)
        /// Show or Hide Reply Button
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
    func configure(indexPath: IndexPath) {
        self.indexPath = indexPath
        self.configureCardUI()
        dateLabel.font = UIFont(name: fontName, size: dateFontSize)
        dateLabel.textColor = VAColorUtility.themeTextIconColor
        dateLabel.text = getMessageSentTime(date: msgDate ??
        Date())
        let isReadMore = self.configurationModal?.result?.integration?[0].readMoreLimit?.readMore ?? false
        let maxTextLimit = self.configurationModal?.result?.integration?[0].readMoreLimit?.characterCount ?? 500
        if isHTMLText(completeText: completeText) {
            // Remove extra space
            completeText = completeText.replacingOccurrences(of: "</p><p><br>", with: "")
            // Fix mailto, call tags
            completeText = completeText.replacingOccurrences(of: "&lt;", with: "<").replacingOccurrences(of: "&gt;", with: ">").replacingOccurrences(of: "/a&gt", with: "/a>")
            // Adding custom font  to html string
            completeText = "<span style=\"font-family: Helvetica; font-size: 16px\">\(completeText)</span>"

            if let attributedText = self.completeText.htmlToAttributedString as? NSMutableAttributedString {
                self.completeAttributedText = attributedText
                self.completeAttributedText?.addAttribute(NSAttributedString.Key.foregroundColor,
                                                          value: VAColorUtility.receiverBubbleTextIconColor,
                                                          range: NSRange(location: 0, length: completeAttributedText!.length))
            }

            readMoreContainerView.isHidden = !isReadMore || completeAttributedText?.length ?? 0 <= maxTextLimit
            textView.attributedText = getAttributedLabelText(isExpanded: isCellExpanded, isFullText: readMoreContainerView.isHidden)
            if completeAttributedText?.length ?? 0 > 10 {
                textView.textAlignment = .left
            } else {
                textView.textAlignment = .center
            }
        } else {
            readMoreContainerView.isHidden = !isReadMore || completeText.count <= maxTextLimit
            textView.text = getLabelText(isExpanded: isCellExpanded, isFullText: readMoreContainerView.isHidden)
            textView.textColor = VAColorUtility.receiverBubbleTextIconColor
            if completeText.count > 10 {
                textView.textAlignment = .left
            } else {
                textView.textAlignment = .center
            }
        }
        readMoreLabel.text = isCellExpanded == true ? "...\(LanguageManager.shared.localizedString(forKey: "Read Less"))" : "...\(LanguageManager.shared.localizedString(forKey: "Read More"))"
        let textWidth = self.textView.attributedText?.width()  ?? containerViewWidth.constant
        DispatchQueue.main.asyncAfter(deadline: .now()+0.001) {
            if textWidth > self.containerViewWidth.constant {
                self.cardViewTrailingEqual.isActive = true
                self.cardViewTrailingGreaterThan.isActive = false
            } else {
                self.cardViewTrailingEqual.isActive = false
                self.cardViewTrailingGreaterThan.isActive = true
            }
        }
        self.replyButton.isHidden = true
//        if VAConfigurations.isChatTool {
//            self.replyButton.isHidden = isChatToolChatClosed ? true : isDoNotRespond
//        }
    }

    func configureCardUI() {
        // self.botImgView.image = UIImage(named: "chatbot", in: Bundle(for: AgentTextCardCell.self), with: nil)
        if !VAConfigurations.isChatTool {
            self.botImgView.image = UIImage(named: "chatbot", in: Bundle(for: TextCardCell.self), with: nil)
        } else {
            if let url = URL(string: self.configurationModal?.result?.avatar ?? "") {
                botImgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
                botImgView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholderImage", in: Bundle(for: TextCardCell.self), with: nil))
            } else {
                self.botImgView.image = UIImage(named: "botDefaultIcon", in: Bundle(for: TextCardCell.self), with: nil)?.withRenderingMode(.alwaysTemplate)
                self.botImgView.tintColor = VAColorUtility.senderBubbleColor
            }
        }
        if configurationModal?.result?.enableAvatar ?? true {
            self.chatBubbleImgView.image = ChatBubble.createChatBubble(isBotMsg: true)
            self.chatBubbleImgView.tintColor = VAColorUtility.receiverBubbleColor

        } else {
            avatarViewWidth.constant = 0
            botImgBGView.isHidden = true
            chatBubbleImgView.image = ChatBubble.createRoundedChatBubble()
        }
        self.replyLabel.textColor = VAColorUtility.receiverBubbleTextIconColor

        if repliedMessageDict.count > 0 {
            if let msg = repliedMessageDict["msg"] as? String {
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
    func getMessageSentTime(date: Date) -> String {
        let currentDateTime = date
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy, h:mm:ss a"
        return formatter.string(from: currentDateTime)
    }
    func getLabelText(isExpanded: Bool, isFullText: Bool) -> String {
        let maxTextLimit = self.configurationModal?.result?.integration?[0].readMoreLimit?.characterCount ?? 500
        if isExpanded || isFullText {
            return completeText
        } else {
            let textToDisplay = Array(completeText.prefix(maxTextLimit))
            return String(textToDisplay)
        }
    }

    func getAttributedLabelText(isExpanded: Bool, isFullText: Bool) -> NSAttributedString {
        let maxTextLimit = self.configurationModal?.result?.integration?[0].readMoreLimit?.characterCount ?? 500
        if isExpanded || isFullText {
            return completeAttributedText!
        } else {
            if let attributedString = completeAttributedText?.attributedSubstring(from: NSRange(location: 0, length: maxTextLimit)) {
                return attributedString
            }
            return completeAttributedText!
        }
    }

    // MARK: Button Actions
    @IBAction func readMoreTapped(_ sender: UIButton) {
        delegate?.didTapReadMoreAgentText(indexPath: self.indexPath)
    }

    @IBAction func replyMessageTapped(_ sender: UIButton) {
        delegate?.didTapOnReply(repliedMessageDict: self.repliedMessageDict, indexPath: self.indexPath)
    }

    @IBAction func replyButtonTapped(_ sender: UIButton) {
        delegate?.didTapOnReplyButton(indexPath: self.indexPath)
    }
}
