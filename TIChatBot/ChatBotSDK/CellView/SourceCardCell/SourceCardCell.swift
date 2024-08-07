// SourceCardCell.swift
// Copyright © 2021 Telus International. All rights reserved.

import UIKit

// MARK: Protocol definition
protocol SourceCardCellDelegate: AnyObject {
    func didTapOnSourceURL(url: String)
}

class SourceCardCell: UITableViewCell {

    // MARK: Outlet Declaration
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var sourceButton: UIButton!
    @IBOutlet weak var containerViewWidth: NSLayoutConstraint!

    // MARK: Property Declaration
    static let nibName = "SourceCardCell"
    static let identifier = "SourceCardCell"
    weak var delegate: SourceCardCellDelegate?
    var sourceUrl: String = ""
    var fontName: String = ""
    var textFontSize: Double = 0.0

    // MARK: Cell lifecycle methods
    override func awakeFromNib() {
        super.awakeFromNib()
        self.sourceButton.setTitle("", for: .normal)
        containerViewWidth.constant = ChatBubble.getChatBubbleWidth()
    }

    // MARK: Custom Methods
    func configure(url: String) {
        sourceUrl = url
        sourceLabel.font = UIFont(name: fontName, size: textFontSize)
    }
    // MARK: Button Actions
    @IBAction func sourceTapped(_ sender: UIButton) {
        delegate?.didTapOnSourceURL(url: sourceUrl)
    }
}
