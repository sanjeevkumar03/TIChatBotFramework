// ImageCardCell.swift
// Copyright © 2021 Telus International. All rights reserved.

import UIKit
import SDWebImage

// MARK: Protocol definition
protocol ImageCardCellDelegate: AnyObject {
    func didTapOnImageCardImage(section: Int, index: Int)
}

class ImageCardCell: UITableViewCell {
    // MARK: Outlet Declaration
    @IBOutlet weak var avatarViewWidth: NSLayoutConstraint!
    @IBOutlet weak var botImgBGView: UIView!
    @IBOutlet weak var botImgView: UIImageView!
    @IBOutlet weak var chatBubbleImgView: UIImageView!
    @IBOutlet weak var msgImgView: UIImageView!
    @IBOutlet weak var msgImgViewWidth: NSLayoutConstraint!
    @IBOutlet weak var msgImgViewHeight: NSLayoutConstraint!
    @IBOutlet weak var containerViewWidth: NSLayoutConstraint!
    
    // MARK: Property Declaration
    static let nibName = "ImageCardCell"
    static let identifier = "ImageCardCell"
    var configurationModal: VAConfigurationModel?
    weak var delegate: ImageCardCellDelegate?
    var isShowBotImage: Bool = true
    var chatTableSection: Int = 0

    lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapImageView(_:)))
        gestureRecognizer.numberOfTapsRequired = 1
        return gestureRecognizer
    }()

    // MARK: Cell lifecycle methods
    override func awakeFromNib() {
        super.awakeFromNib()
        self.msgImgView.layer.cornerRadius = 4
        msgImgView.addGestureRecognizer(tapGestureRecognizer)
        containerViewWidth.constant = ChatBubble.getChatBubbleWidth()
        msgImgView.contentMode = .scaleAspectFit
        msgImgView.clipsToBounds = true
        msgImgView.translatesAutoresizingMaskIntoConstraints = false
    }

    // MARK: Custom methods
    /// Used to configure image card
    /// - Parameter imageURL: It accepts image url string.
    func configure(imageURL: String) {
        chatBubbleImgView.tintColor = VAColorUtility.receiverBubbleColor
        if let url = URL(string: imageURL) {
            if msgImgView.accessibilityHint != "\(url)" || imageURL.hasSuffix(".gif") {
                if msgImgView.accessibilityHint == "\(url)" { /// This is done to show gif image animation
                    self.msgImgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
                    self.msgImgView.accessibilityHint = "\(url)"
                    self.msgImgView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholderImage", in: Bundle(for: ImageCardCell.self), with: nil))
                } else {
                    /*self.layoutIfNeeded()
                    DispatchQueue.global(qos: .default).async {
                        if let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil) {
                            if let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as Dictionary? {
                                let pixelWidth = imageProperties[kCGImagePropertyPixelWidth] as! CGFloat
                                let pixelHeight = imageProperties[kCGImagePropertyPixelHeight] as! CGFloat
                                print("the image width is: \(pixelWidth)")
                                print("the image height is: \(pixelHeight)")
                                let ratioWidth: CGFloat = pixelWidth/pixelHeight
                                let ratioHeight: CGFloat = pixelHeight/pixelWidth
                                let imageViewWidth: CGFloat = self.containerViewWidth.constant - 78
                                DispatchQueue.main.asyncAfter(deadline: .now()) {
                                    if ratioWidth == 1 { ///width equal to height
                                        self.msgImgViewWidth.constant = imageViewWidth
                                        self.msgImgViewHeight.constant = imageViewWidth
                                    } else if ratioWidth > 1 { ///width higher than height
                                        self.msgImgViewWidth.constant = imageViewWidth
                                        self.msgImgViewHeight.constant = imageViewWidth * 0.5//ratioHeight
                                    } else { ///rectangular with height higher than width
                                        self.msgImgViewWidth.constant = imageViewWidth * 0.5//ratioWidth
                                        self.msgImgViewHeight.constant = imageViewWidth
                                    }
                                }
                                //ratio = ratio > 1 ? 1.5 : (ratio < 1 ? 0.5 : ratio)
                                //self.msgImgViewHeight.constant = self.msgImgView.frame.size.width * ratio
                            }
                        }
                    }*/
//                    let imageViewWidth: CGFloat = self.containerViewWidth.constant - 78
//                    self.msgImgViewWidth.constant = imageViewWidth
//                    self.msgImgViewHeight.constant = imageViewWidth*0.4
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.msgImgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
                        self.msgImgView.accessibilityHint = "\(url)"
                        self.msgImgView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholderImage", in: Bundle(for: ImageCardCell.self), with: nil))
                    }
                    
                }
            }
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
    /// This function handles tap on imageView
    /// - Parameter sender: UITapGestureRecognizer
    @objc func didTapImageView(_ sender: UITapGestureRecognizer) {
        if let index = sender.view?.tag {
            delegate?.didTapOnImageCardImage(section: chatTableSection, index: index)
        }
    }
}
