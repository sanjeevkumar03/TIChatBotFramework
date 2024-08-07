// AnsTagsCollectionViewCell.swift
// Copyright © 2021 Telus International. All rights reserved.

import UIKit

class AnsTagsCollectionViewCell: UICollectionViewCell {

    // MARK: Outlet declaration
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var container: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.container.layer.cornerRadius = 4
        self.container.layer.masksToBounds = true
    }
}
