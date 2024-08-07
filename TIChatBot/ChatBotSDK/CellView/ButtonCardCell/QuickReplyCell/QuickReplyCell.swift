// QuickReplyCell.swift
// Copyright © 2021 Telus International. All rights reserved.

import UIKit

// MARK: Protocol definition
protocol QuickReplyCellDelegate: AnyObject {
    func didTapQuickReplyButton(response: BotQRButton, index: Int)
}

class QuickReplyCell: UICollectionViewCell {

    // MARK: Outlet Declaration
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var quickReplyButton: UIButton!
    @IBOutlet weak var quickReplyBottom: NSLayoutConstraint!

    // MARK: Property Declaration
    static let nibName = "QuickReplyCell"
    static let identifier = "QuickReplyCell"
    weak var delegate: QuickReplyCellDelegate?
    var buttonResponse: BotQRButton?
    var allowUserActivity: Bool = false
    var isButtonClicked: Bool = false

    // MARK: Cell lifecycle methods
    override func awakeFromNib() {
        super.awakeFromNib()
        quickReplyButton.setTitle("", for: .normal)
    }

    // MARK: Custom methods
    func configure(item: BotQRButton?) {
        buttonResponse = item
        self.titleLabel.attributedText = item?.attributedText
        self.titleLabel.textColor = isButtonClicked ? VAColorUtility.buttonColor.withAlphaComponent(0.35) : VAColorUtility.buttonColor
        containerView.layer.borderColor = isButtonClicked ? VAColorUtility.buttonColor.withAlphaComponent(0.35).cgColor : VAColorUtility.buttonColor.cgColor
        self.titleLabel.textAlignment = .center
        self.titleLabel.lineBreakMode = .byTruncatingTail
        self.isUserInteractionEnabled = allowUserActivity
    }

    func configureCardUI() {
        containerView.layer.borderColor = isButtonClicked ? VAColorUtility.buttonColor.withAlphaComponent(0.35).cgColor : VAColorUtility.buttonColor.cgColor
        titleLabel.textColor = isButtonClicked ? VAColorUtility.buttonColor.withAlphaComponent(0.35) : VAColorUtility.buttonColor
    }

    // MARK: Button actions
    @IBAction func buttonAction(_ sender: UIButton) {
        self.isUserInteractionEnabled = false
        delegate?.didTapQuickReplyButton(response: buttonResponse!, index: sender.tag)
    }

}
