// CarouselOptionCell.swift
// Copyright © 2021 Telus International. All rights reserved.

import UIKit

// MARK: Protocol definition
protocol CarouselOptionCellDelegate: AnyObject {
    func didTapQuickReplyButton(response: BotQRButton)
}

class CarouselOptionCell: UITableViewCell {

    // MARK: Outlet Declaration
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var quickReplyButton: UIButton!

    // MARK: Property Declaration
    static let nibName = "CarouselOptionCell"
    static let identifier = "CarouselOptionCell"
    weak var delegate: CarouselOptionCellDelegate?
    var isButtonClicked: Bool = false

    // MARK: Cell lifecycle methods
    override func awakeFromNib() {
        super.awakeFromNib()
        quickReplyButton.setTitle("", for: .normal)
    }

    // MARK: Custom methods
    func configureCardUI() {
        containerView.layer.borderColor = isButtonClicked ? VAColorUtility.buttonColor.withAlphaComponent(0.35).cgColor : VAColorUtility.buttonColor.cgColor
        titleLabel.textColor = isButtonClicked ? VAColorUtility.buttonColor.withAlphaComponent(0.35) : VAColorUtility.buttonColor
    }

    // MARK: Button actions
    @IBAction func buttonAction(_ sender: UIButton) {
        // delegate?.didTapQuickReplyButton(response: buttonResponse!)
    }
}
