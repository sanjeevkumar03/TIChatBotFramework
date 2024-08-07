//  SenderImageCell.swift
// Copyright © 2021 Telus International. All rights reserved.

import UIKit
import SDWebImage
import MapKit

// MARK: Protocol definition
protocol SenderImageCellDelegate: AnyObject {
    func didTapOnImage(image: UIImage)
}

class SenderImageCell: UITableViewCell {
    // MARK: Outlet Declaration
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var chatBubbleImgView: UIImageView!
    @IBOutlet weak var containerViewWidth: NSLayoutConstraint!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dateLabelTop: NSLayoutConstraint!
    @IBOutlet weak var dateLabelBottom: NSLayoutConstraint!
    @IBOutlet weak var avatarViewWidth: NSLayoutConstraint!
    @IBOutlet weak var avatarView: UIView!
    @IBOutlet weak var msgImgView: UIImageView!

    // MARK: Property Declaration
    static let nibName = "SenderImageCell"
    static let identifier = "SenderImageCell"
    var bubbleColor: UIColor = .white
    var configurationModal: VAConfigurationModel?
    var fontName: String = ""
    var textFontSize: Double = 0.0
    var dateFontSize: Double = 0.0
    var locationData: String = ""
    weak var delegate: SenderImageCellDelegate?
    lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapImageView(_:)))
        gestureRecognizer.numberOfTapsRequired = 1
        return gestureRecognizer
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        chatBubbleImgView.tintColor = bubbleColor
        self.msgImgView.layer.cornerRadius = 4
        msgImgView.addGestureRecognizer(tapGestureRecognizer)
        containerViewWidth.constant = ChatBubble.getChatBubbleWidth()
        msgImgView.contentMode = .scaleAspectFit
        msgImgView.clipsToBounds = true
    }

    func configure(sentiment: Int?, date: Date, image: UIImage?) {
        if let image = image {
            msgImgView.image = image
        }
        self.chatBubbleImgView.tintColor = VAColorUtility.senderBubbleColor
        self.imgView.image = self.getSenderImage(sentiment: sentiment)
        self.imgView.tintColor = VAColorUtility.themeTextIconColor
        self.dateLabel.font  = UIFont(name: fontName, size: dateFontSize)
        self.dateLabel.textColor = VAColorUtility.themeTextIconColor
        self.dateLabel.text = self.getCurrentTime(date: date)
        self.setCardUI()
    }

    func setCardUI() {
        if configurationModal?.result?.enableAvatar ?? true {
            avatarView.isHidden = false
            chatBubbleImgView.image = ChatBubble.createChatBubble(isBotMsg: false)
        } else {
            avatarViewWidth.constant = 0
            avatarView.isHidden = true
            chatBubbleImgView.image = ChatBubble.createRoundedChatBubble()
        }
    }

    /// This function returns images based on the provided sentiment value
    /// - Parameter sentiment: sentiment value
    /// - Returns: sender image
    private func getSenderImage(sentiment: Int?) -> UIImage {
        if sentiment == 1 {
            return UIImage(named: "emoji7", in: Bundle(for: VAChatViewController.self), with: nil)!
        } else if sentiment == -1 {
            return UIImage(named: "emoji3", in: Bundle(for: VAChatViewController.self), with: nil)!
        } else {
            return UIImage(named: "emoji6", in: Bundle(for: VAChatViewController.self), with: nil)!
        }
    }

    /// This function formats the date
    /// - Parameter date: Input date
    /// - Returns: returns formatted date
    private func getCurrentTime(date: Date) -> String {
        let currentDateTime = date
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy, h:mm:ss a"
        return formatter.string(from: currentDateTime)
    }

    /// This function handles tap on imageView
    /// - Parameter sender: UITapGestureRecognizer
    @objc func didTapImageView(_ sender: UITapGestureRecognizer) {
        if locationData.isEmpty {
            delegate?.didTapOnImage(image: msgImgView.image ?? UIImage())
        } else {
            let location = locationData.components(separatedBy: ",")
            if location.count > 1 {
                let latitude = location[0]
                let longitude = location[1]
                // UIApplication.shared.open(URL(string: "https://maps.apple.com/maps?ll=\(latitude),\(longitude)")!, options: [:], completionHandler: nil)
                    let regionDistance: CLLocationDistance = 500
                let coordinates = CLLocationCoordinate2DMake(CLLocationDegrees(floatLiteral: Double(latitude)!), CLLocationDegrees(floatLiteral: Double(longitude)!))
                let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
                    let options = [
                        MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                        MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
                    ]
                    let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
                    let mapItem = MKMapItem(placemark: placemark)
                    mapItem.openInMaps(launchOptions: options)
            }
        }
    }

}
