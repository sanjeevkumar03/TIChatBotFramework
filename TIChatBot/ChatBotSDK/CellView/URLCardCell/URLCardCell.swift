// URLCardCell.swift
// Copyright © 2021 Telus International. All rights reserved.

import UIKit
import SDWebImage

// MARK: Protocol definition
protocol URLCardCellDelegate: AnyObject {
    func didTapOnURL(url: String)
}

class URLCardCell: UITableViewCell {
    // MARK: Outlet Declaration
    @IBOutlet weak var avatarViewWidth: NSLayoutConstraint!
    @IBOutlet weak var botImgBGView: UIView!
    @IBOutlet weak var botImgView: UIImageView!
    @IBOutlet weak var chatBubbleImgView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var urlButton: UIButton!
    @IBOutlet weak var containerViewWidth: NSLayoutConstraint!
    @IBOutlet weak var cardViewTrailingEqual: NSLayoutConstraint!
    @IBOutlet weak var cardViewTrailingGreaterThan: NSLayoutConstraint!

    // MARK: Property Declaration
    static let nibName = "URLCardCell"
    static let identifier = "URLCardCell"
    var configurationModal: VAConfigurationModel?
    weak var delegate: URLCardCellDelegate?
    var isShowBotImage: Bool = true
    var fontName: String = ""
    var textFontSize: Double = 0.0

    // MARK: Cell lifecycle methods
    override func awakeFromNib() {
        super.awakeFromNib()
        containerViewWidth.constant = ChatBubble.getChatBubbleWidth()
        urlButton.setTitle("", for: .normal)
    }

    // MARK: Custom methods
    /// Used to configure url card
    /// - Parameter url: It accepts url string.
    func configure(url: String) {
        chatBubbleImgView.tintColor = VAColorUtility.receiverBubbleColor
        self.titleLabel.attributedText = NSAttributedString(string: url,
                                                            attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue, .font: UIFont(name: fontName, size: textFontSize)!])

        let textWidth = self.titleLabel.attributedText?.width()  ?? containerViewWidth.constant
        if textWidth > containerViewWidth.constant {
            cardViewTrailingEqual.isActive = true
            cardViewTrailingGreaterThan.isActive = false
        } else {
            cardViewTrailingEqual.isActive = false
            cardViewTrailingGreaterThan.isActive = true
        }
        self.setCardUI()
    }
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
    func setBotImage() {
        if let url = URL(string: self.configurationModal?.result?.avatar ?? "") {
            botImgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            botImgView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholderImage", in: Bundle(for: TextCardCell.self), with: nil))
        } else {
            self.botImgView.image = UIImage(named: "botDefaultIcon", in: Bundle(for: TextCardCell.self), with: nil)?.withRenderingMode(.alwaysTemplate)
            self.botImgView.tintColor = VAColorUtility.senderBubbleColor
        }
    }
    // MARK: Button Actions
    @IBAction func urlTapped(_ sender: UIButton) {
        delegate?.didTapOnURL(url: self.titleLabel.text ?? "")
        debugPrint("URL: \(self.titleLabel.text ?? "")")
    }
}
