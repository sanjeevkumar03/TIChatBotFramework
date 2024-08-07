// ButtonCardCell.swift
// Copyright © 2021 Telus International. All rights reserved.

import UIKit
import SDWebImage

// MARK: Protocol definition
protocol ButtonCardCellDelegate: AnyObject {
    func didTapSSOButton(response: BotQRButton, cardIndexPath: IndexPath, ssoType: String)
    func didTapQuickReplyButton(response: BotQRButton, context: [Dictionary<String, Any>], cardIndexPath: IndexPath, selectedButtonIndex: Int)
}

class ButtonCardCell: UITableViewCell {
    // MARK: Outlet Declaration
    @IBOutlet weak var avatarViewWidth: NSLayoutConstraint!
    @IBOutlet weak var botImgBGView: UIView!
    @IBOutlet weak var botImgView: UIImageView!
    @IBOutlet weak var chatBubbleImgView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var SSOContainerView: UIView!
    @IBOutlet weak var SSOButton: UIButton!
    @IBOutlet weak var SSOBtnTitleLabel: UILabel!
    @IBOutlet weak var SSOContainerBottom: NSLayoutConstraint!
    @IBOutlet weak var SSOContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var SSOContainerLeading: NSLayoutConstraint!
    @IBOutlet weak var SSOContainerTrailing: NSLayoutConstraint!
    @IBOutlet weak var collectionContainerView: UIView!
    @IBOutlet weak var collectionContainerLeading: NSLayoutConstraint!
    @IBOutlet weak var collectionContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionContainerSuperviewTop: NSLayoutConstraint!
    @IBOutlet weak var collectionContainerTop: NSLayoutConstraint!
    @IBOutlet weak var buttonCollectionWidth: NSLayoutConstraint!
    @IBOutlet weak var buttonCollectionHeight: NSLayoutConstraint!
    @IBOutlet weak var buttonsCollection: UICollectionView!
    @IBOutlet weak var containerViewWidth: NSLayoutConstraint!
    @IBOutlet weak var cardViewTrailingEqual: NSLayoutConstraint!
    @IBOutlet weak var cardViewTrailingGreaterThan: NSLayoutConstraint!
    @IBOutlet weak var buttonCollectionTop: NSLayoutConstraint!
    @IBOutlet weak var textWithSSObottom: NSLayoutConstraint!

    // MARK: Property Declaration
    static let nibName = "ButtonCardCell"
    static let identifier = "ButtonCardCell"
    let buttonMinimumWidth: CGFloat = 80
    typealias CardControlsWidth = (titleWidth: CGFloat, ssoButtonWidth: CGFloat, quickReplyBtnWithLongestTextWidth: CGFloat)
    var configurationModal: VAConfigurationModel?
    var context: [Dictionary<String, Any>] = []
    var quickReplyResponse: QuickReply?
    let flowLayout = UICollectionViewFlowLayout()
    weak var delegate: ButtonCardCellDelegate?
    var isHideQuickReplyButton: Bool = false
    var cardIndexPath: IndexPath?
    var isShowBotImage: Bool = true
    let quickReplyCollectionMaxWidth = UIScreen.main.bounds.width-100
    var cardButtonsWidth: CardControlsWidth?
    var fontName: String = ""
    var textFontSize: Double = 0.0
    var allowUserActivity: Bool = false

    // MARK: Cell lifecycle methods
    override func awakeFromNib() {
        super.awakeFromNib()
        SSOButton.setTitle("", for: .normal)
        containerViewWidth.constant = ChatBubble.getChatBubbleWidth()
        cardViewTrailingGreaterThan.isActive = true
    }

    // MARK: Custom methods
    func configure() {
        self.layoutIfNeeded()
        SSOContainerView.clipsToBounds = true
        SSOContainerView.layer.cornerRadius = 12
        SSOContainerView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        self.configureCardUI()
        self.setCardWidth()
        self.SSOBtnTitleLabel.font = UIFont(name: fontName, size: textFontSize)
        if quickReplyResponse?.title == "" {
            self.titleLabel.isHidden = true
        } else {
            self.titleLabel.isHidden = false
            self.chatBubbleImgView.isHidden = false
            let attributedStr: NSMutableAttributedString = quickReplyResponse?.attributedTitle ?? NSMutableAttributedString(string: "")
            attributedStr.addAttribute(.font, value: UIFont(name: fontName, size: textFontSize)!, range: NSRange(location: 0, length: attributedStr.length))
            self.titleLabel.attributedText = attributedStr
        }
        if configurationModal?.result?.quickReply == false && isHideQuickReplyButton == true {
            SSOContainerView.isHidden = true
            SSOContainerHeight.constant = 0
            collectionContainerView.isHidden = true
            self.collectionContainerHeight.isActive = true
            textWithSSObottom.isActive = true
        } else {
            textWithSSObottom.isActive = false
            if quickReplyResponse?.ssoButton == nil {
                SSOContainerView.isHidden = true
                SSOContainerHeight.constant = 0
            } else {
                SSOContainerView.isHidden = false
                self.SSOBtnTitleLabel.attributedText = self.quickReplyResponse?.ssoButton?.attributedText
                self.SSOBtnTitleLabel.textAlignment = .center
                self.SSOBtnTitleLabel.textColor = VAColorUtility.buttonColor

                SSOContainerHeight.constant = 40
                SSOContainerLeading.constant = isShowBotImage ? 12 : 9
                // SSOContainerTrailing.constant = isShowBotImage ? 3 : 4
            }

            if quickReplyResponse?.title == "" && quickReplyResponse?.ssoButton == nil {
                chatBubbleImgView.isHidden = true
                collectionContainerSuperviewTop.isActive = true
                collectionContainerTop.isActive = false
                SSOContainerBottom.constant = 0
                buttonCollectionTop.constant = 0
            } else {
                chatBubbleImgView.isHidden = false
                collectionContainerSuperviewTop.isActive = false
                collectionContainerTop.isActive = true
                SSOContainerBottom.constant = 4
                buttonCollectionTop.constant = 0// 5
            }

            if quickReplyResponse?.otherButtons.count ?? 0 > 0 {
                self.collectionContainerView.isHidden = false
                self.collectionContainerHeight.isActive = false
            } else {
                collectionContainerView.isHidden = true
                self.collectionContainerHeight.isActive = true
            }
            if configurationModal?.result?.enableAvatar ?? true {
                collectionContainerLeading.constant = isShowBotImage ? 60 : 56
            } else {
                collectionContainerLeading.constant = isShowBotImage ? 20 : 16
            }
            self.configureButtonCollectionLayout()
            DispatchQueue.main.asyncAfter(deadline: .now()+0.01) {
                UIView.performWithoutAnimation {
                    self.buttonsCollection.reloadData()
                }
            }
            self.buttonsCollection.flashScrollIndicators()
            self.buttonsCollection.contentOffset = .zero
        }
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
        SSOBtnTitleLabel.textColor = VAColorUtility.buttonColor
        SSOContainerView.layer.borderColor = VAColorUtility.buttonColor.cgColor
        titleLabel.textColor = VAColorUtility.receiverBubbleTextIconColor
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
    /// This function is used to configure button collection which shows button at the bottom of button card if available.
    func configureButtonCollection() {
        self.buttonsCollection.register(UINib(nibName: QuickReplyCell.nibName, bundle: Bundle(for: ButtonCardCell.self)), forCellWithReuseIdentifier: QuickReplyCell.identifier)
        self.buttonsCollection.layoutIfNeeded()
        self.buttonsCollection.delegate = self
        self.buttonsCollection.dataSource = self
    }
    func configureButtonCollectionLayout() {
        if (configurationModal?.result?.integration?[0].horizontalQuickReply == true) {
            flowLayout.scrollDirection = .horizontal
            buttonCollectionHeight.constant = 50
            buttonsCollection.isScrollEnabled = true
            flowLayout.minimumInteritemSpacing = 10
        } else {
            flowLayout.scrollDirection = .vertical
            buttonCollectionHeight.constant = CGFloat(self.quickReplyResponse?.otherButtons.count ?? 0) * (45 + 5)
            buttonsCollection.isScrollEnabled = false
            flowLayout.minimumLineSpacing = 5
        }
        self.buttonsCollection.collectionViewLayout = flowLayout
        self.configureButtonCollection()
    }

    func getWidthOfControls() -> CardControlsWidth {
        var buttonsText = ""
        if configurationModal?.result?.integration?[0].horizontalQuickReply == false {
            // Considering item with largest text from array
            if let largestButton = self.quickReplyResponse?.otherButtons.max(by: {$1.text.count > $0.text.count}) {
                buttonsText = largestButton.text
            }
        }
        let buttonsWithLongestTextWidth: CGFloat =  buttonsText.size(OfFont: UIFont(name: fontName, size: textFontSize)!).width
        let titleWidth: CGFloat =  quickReplyResponse?.title.size(OfFont: UIFont(name: fontName, size: textFontSize)!).width ?? 0
        let ssoButtonWidth: CGFloat = quickReplyResponse?.ssoButton?.text.size(OfFont: UIFont(name: fontName, size: textFontSize)!).width ?? 0
        return CardControlsWidth(titleWidth, ssoButtonWidth, buttonsWithLongestTextWidth)
    }

    func setCardWidth() {
        cardButtonsWidth = getWidthOfControls()
        if self.configurationModal?.result?.integration?[0].horizontalQuickReply == true {
            self.buttonCollectionWidth.constant = self.quickReplyCollectionMaxWidth
        } else {
            if cardButtonsWidth!.quickReplyBtnWithLongestTextWidth > self.quickReplyCollectionMaxWidth {
                self.buttonCollectionWidth.constant = self.quickReplyCollectionMaxWidth
            } else {
                let calculatedWidth = self.cardButtonsWidth!.quickReplyBtnWithLongestTextWidth + 30
                self.buttonCollectionWidth.constant = calculatedWidth < buttonMinimumWidth ? buttonMinimumWidth : calculatedWidth
            }
        }
    }

    // MARK: Button Actions
    @IBAction func SSOButtonTapped(_ sender: UIButton) {
        if let ssoButton = quickReplyResponse?.ssoButton {
            delegate?.didTapSSOButton(response: ssoButton, cardIndexPath: cardIndexPath!, ssoType: quickReplyResponse?.ssoType ?? "")
        }
    }

}

// MARK: UICollectionViewDelegate & UICollectionViewDataSource
extension ButtonCardCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return quickReplyResponse?.otherButtons.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let buttonCell = collectionView.dequeueReusableCell(withReuseIdentifier: QuickReplyCell.identifier, for: indexPath)
        if indexPath.item >= (quickReplyResponse?.otherButtons.count ?? 0) {
            return buttonCell
        }
        if let cell = buttonCell as? QuickReplyCell {
            cell.quickReplyButton.tag = indexPath.item
            cell.allowUserActivity = allowUserActivity
            cell.isButtonClicked = quickReplyResponse?.otherButtons[indexPath.item].isButtonClicked ?? false
            cell.configure(item: quickReplyResponse?.otherButtons[indexPath.item])
            cell.delegate = self
            cell.quickReplyBottom.constant = configurationModal?.result?.integration?[0].horizontalQuickReply == true ? 10 : 0
            cell.titleLabel.font = UIFont(name: fontName, size: textFontSize-1)
            return cell
        }
        return buttonCell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item >= (quickReplyResponse?.otherButtons.count ?? 0) {
            return CGSize(width: 0, height: 0)
        }
        var buttonWidthWithMaxText: CGFloat = 0
        if configurationModal?.result?.integration?[0].horizontalQuickReply == false {
            for item in quickReplyResponse!.otherButtons {
                let attributedText = item.attributedText!
                let titleWidth = attributedText.width()
                buttonWidthWithMaxText = titleWidth > buttonWidthWithMaxText ? titleWidth : buttonWidthWithMaxText
            }
            buttonWidthWithMaxText += 10
        }
        if configurationModal?.result?.integration?[0].horizontalQuickReply == true {
            var textWidth = ((quickReplyResponse?.otherButtons[indexPath.item].attributedText?.width() ?? 50.0) + 20)
            let chatBubbleWidth = ChatBubble.getChatBubbleWidth() - 50
            textWidth = textWidth > chatBubbleWidth ? chatBubbleWidth : textWidth
            let cellWidth = textWidth < self.buttonMinimumWidth ? self.buttonMinimumWidth : textWidth
            return CGSize(width: cellWidth, height: 50 )
        } else if buttonWidthWithMaxText < quickReplyCollectionMaxWidth && (quickReplyResponse?.otherButtons.count ?? 0) > 1 {
            let cellWidth = buttonWidthWithMaxText < self.buttonMinimumWidth ? self.buttonMinimumWidth : buttonWidthWithMaxText
            return CGSize(width: cellWidth, height: 45 )
        } else {
            return CGSize(width: collectionView.bounds.width, height: 45)
        }
    }
}

// MARK: QuickReplyCellDelegate
extension ButtonCardCell: QuickReplyCellDelegate {
    func didTapQuickReplyButton(response: BotQRButton, index: Int) {
        delegate?.didTapQuickReplyButton(response: response, context: self.context, cardIndexPath: cardIndexPath!, selectedButtonIndex: index)
    }
}
