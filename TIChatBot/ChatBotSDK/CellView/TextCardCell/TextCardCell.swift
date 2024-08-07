// TextCardCell.swift
// Copyright © 2021 Telus International. All rights reserved.

import UIKit
import SDWebImage
import WebKit

// MARK: Protocol definition
protocol TextCardCellDelegate: AnyObject {
    func didTapReadMore(section: Int, index: Int)
    func didTapOnSourceURL(url: String)
    func didTapOnTextAttachment(image: UIImage)
    func didTapOnQueryLink(displayText: String, dataQuery: String, indexPath: IndexPath)
}

class TextCardCell: UITableViewCell {
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
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var sourceButton: UIButton!
    @IBOutlet weak var sourceView: UIView!
    @IBOutlet weak var sourceViewHeight: NSLayoutConstraint!
    @IBOutlet weak var textCardViewBottom: NSLayoutConstraint!

    // MARK: Property Declaration
    static let nibName = "TextCardCell"
    static let identifier = "TextCardCell"
    var isCellExpanded: Bool = false
    var completeText: String = ""
    var originalText: String = ""
    var completeAttributedText: NSMutableAttributedString?
    var configurationModal: VAConfigurationModel?
    weak var delegate: TextCardCellDelegate?
    var textItem: TextItem?
    var isShowBotImage: Bool = true
    var isAgent: Bool = false
    var chatTableSection: Int = 0
    var fontName: String = ""
    var textFontSize: Double = 0.0

    // MARK: Cell lifecycle methods
    override func awakeFromNib() {
        super.awakeFromNib()
        containerViewWidth.constant = ChatBubble.getChatBubbleWidth()
        readMoreButton.setTitle("", for: .normal)
        self.sourceButton.setTitle("", for: .normal)
        textView.tintColor = #colorLiteral(red: 0, green: 0.3647058824, blue: 1, alpha: 1)
        textView.delegate = self
    }

    // MARK: Custom methods
    func configure() {
        self.configureCardUI()
        let isReadMore = self.configurationModal?.result?.integration?[0].readMoreLimit?.readMore ?? false
        let maxTextLimit = self.configurationModal?.result?.integration?[0].readMoreLimit?.characterCount ?? 500
        originalText = completeText
        if isHTMLText(completeText: completeText) {
            let imageUrls = getImagesFromHtml(for: "<img[^>]+src=\"([^\">]+)\"", in: String(completeText))
            if !imageUrls.isEmpty && completeAttributedText?.length ?? 0 > 50 && completeAttributedText?.length ?? 0 <= maxTextLimit {
                readMoreContainerView.isHidden = !isReadMore
            } else {
                readMoreContainerView.isHidden = !isReadMore || completeAttributedText?.length ?? 0 <= maxTextLimit
            }
            // https://gist.github.com/hashaam/31f51d4044a03473c18a168f4999f063
            self.textView.attributedText = self.getAttributedLabelText(isExpanded: self.isCellExpanded, isFullText: self.readMoreContainerView.isHidden)

            if completeAttributedText?.length ?? 0 > 10 {
                textView.textAlignment = .left
            } else {
                textView.textAlignment = .center
            }
        } else {
            readMoreContainerView.isHidden = !isReadMore || completeAttributedText?.length ?? 0 <= maxTextLimit
            self.textView.attributedText = self.getAttributedLabelText(isExpanded: self.isCellExpanded, isFullText: self.readMoreContainerView.isHidden)

            if completeAttributedText?.length ?? 0 > 10 {
                self.textView.textAlignment = .left
            } else {
                self.textView.textAlignment = .center
            }
            textView.isHidden = false
        }
        readMoreLabel.text = isCellExpanded == true ? "...\(LanguageManager.shared.localizedString(forKey: "Read Less"))" : "...\(LanguageManager.shared.localizedString(forKey: "Read More"))"
        readMoreLabel.font = UIFont(name: fontName, size: textFontSize)
        let textWidth = self.textView.attributedText?.width()  ?? containerViewWidth.constant
        if textWidth > containerViewWidth.constant {
            cardViewTrailingEqual.isActive = true
            cardViewTrailingGreaterThan.isActive = false
        } else {
            cardViewTrailingEqual.isActive = false
            cardViewTrailingGreaterThan.isActive = true
        }
        sourceLabel.font = UIFont(name: fontName, size: textFontSize)
    }
    func configureCardUI() {
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

        chatBubbleImgView.tintColor = VAColorUtility.receiverBubbleColor
        if textItem?.source == nil {
            sourceView.isHidden = true
            sourceViewHeight.constant = 0
            textCardViewBottom.isActive = false
        } else {
            sourceView.isHidden = false
            sourceViewHeight.constant = 30
            textCardViewBottom.isActive = true
        }
    }

    func setBotImage() {
        if self.isAgent && !VAConfigurations.isChatTool {
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
        let imageUrls = getImagesFromHtml(for: "<img[^>]+src=\"([^\">]+)\"", in: String(completeText))
        let maxTextLimit = self.configurationModal?.result?.integration?[0].readMoreLimit?.characterCount ?? 200
        if isExpanded || isFullText {
            let attributedText = completeAttributedText
            if attributedText?.length ?? 0 > 0 {
                //attributedText?.addAttribute(.font, value: UIFont(name: fontName, size: textFontSize)!, range: NSRange(location: 0, length: attributedText!.length))
                return attributedText!
            } else {
                return NSAttributedString(string: "")
            }

        } else {
            if !imageUrls.isEmpty && completeAttributedText?.length ?? 0 > 50 && completeAttributedText?.length ?? 0 <= maxTextLimit {
                if let attributedString = completeAttributedText?.attributedSubstring(from: NSRange(location: 0, length: (completeAttributedText?.string.count ?? 50)-(imageUrls.count+2))) {
                    let attributedText: NSMutableAttributedString = attributedString as? NSMutableAttributedString ?? NSMutableAttributedString(string: "")
                    //attributedText.addAttribute(.font, value: UIFont(name: fontName, size: textFontSize)!, range: NSRange(location: 0, length: attributedText.length))
                    return attributedText
                }
            } else {
                let length = completeAttributedText?.length ?? 0 > maxTextLimit ? maxTextLimit : (completeAttributedText?.length ?? 0)-1
                if let attributedString = completeAttributedText?.attributedSubstring(from: NSRange(location: 0, length: length)) {
                    let attributedText: NSMutableAttributedString = attributedString as? NSMutableAttributedString ?? NSMutableAttributedString(string: "")
                    //attributedText.addAttribute(.font, value: UIFont(name: fontName, size: textFontSize)!, range: NSRange(location: 0, length: attributedText.length))
                    return attributedText
                }
            }
            let attributedText = completeAttributedText
            //attributedText?.addAttribute(.font, value: UIFont(name: fontName, size: textFontSize)!, range: NSRange(location: 0, length: attributedText!.length))
            return attributedText!
        }
    }

    // MARK: Button Actions
    @IBAction func readMoreTapped(_ sender: UIButton) {
        delegate?.didTapReadMore(section: chatTableSection, index: sender.tag)
    }
    @IBAction func sourceTapped(_ sender: UIButton) {
        delegate?.didTapOnSourceURL(url: textItem?.source?.onesource ?? "")
    }
}

extension TextCardCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if let attachment = textAttachment.image {
            delegate?.didTapOnTextAttachment(image: attachment)
        }
        return true
    }
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        print(URL)
        if UIApplication.shared.canOpenURL(URL) == false {
            let newRange = Range(characterRange, in: textView.text ?? "")!
            let subString = textView.text[newRange]
            let queryLink = String(subString)
            let chatTableIndexPath = IndexPath(row: readMoreButton.tag, section: chatTableSection)
            let dataQuery = self.getDataQueryAttributeFromHtmlString(queryText: queryLink)
            delegate?.didTapOnQueryLink(displayText: queryLink, dataQuery: dataQuery, indexPath: chatTableIndexPath)
            return false
        } else {
            delegate?.didTapOnSourceURL(url: URL.absoluteString)
            return false
        }
        //return true
    }
    func getDataQueryAttributeFromHtmlString(queryText: String) -> String {
        var splittedText = originalText.components(separatedBy: "data-query")
        splittedText.removeFirst()
        for item in splittedText {
            if item.contains("data-displayname=\"\(queryText)\"") || item.contains("data-displayname=\" \(queryText)\"") || item.contains("data-displayname=\"\(queryText) \"") || item.contains("data-displayname=\" \(queryText) \"") {
                let splittedItem = item.components(separatedBy: "data-displayname")
                let dataQuery = splittedItem.first ?? ""
                return dataQuery.replacingOccurrences(of: "=\"", with: "").replacingOccurrences(of: "\"", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        return ""
    }
}

extension String {
    var isValidURL: Bool {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector?.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            // it is a link, if the match covers the whole string
            return match.range.length == self.utf16.count
        } else {
            return false
        }
    }
}
