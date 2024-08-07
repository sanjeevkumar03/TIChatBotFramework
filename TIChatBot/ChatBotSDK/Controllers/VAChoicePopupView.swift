// VAChoicePopupView.swift
// Copyright © 2021 Telus International. All rights reserved.

import UIKit

class VAChoicePopupView: UIViewController {

    // MARK: Outlet declaration
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var seperatorTitleView: UIView!
    @IBOutlet weak var seperatorConfirmView: UIView!
    @IBOutlet weak var crossImgView: UIImageView!
    @IBOutlet weak var crossButton: UIButton!
    @IBOutlet weak var optionsTable: UITableView! {
        didSet {
            // Confirm delegate and datasource
            self.optionsTable.delegate = self
            self.optionsTable.dataSource = self
            // Register UITableviewCell nib
            self.optionsTable.register(UINib(nibName: ChoiceCardOptionCell.nibName, bundle: Bundle(for: ChoiceCardCell.self)), forCellReuseIdentifier: ChoiceCardOptionCell.identifier)
            // Estimated row height
            self.optionsTable.estimatedRowHeight = 50
        }
    }
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var confirmView: UIView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var hConfirmButtonConst: NSLayoutConstraint!
    @IBOutlet weak var hTableViewConst: NSLayoutConstraint!

    // MARK: Property declaration
    private var isMultiSelect: Bool = true
    private var arrayOfData: [Choice] = []
    private var indexPath: IndexPath!
    private var completionBlock: VAChoiceCompletionBlock!
    private var fontName: String = ""
    private var textFontSize: Double = 0.0
    let confirmStaticText = LanguageManager.shared.localizedString(forKey: "Confirm")

    // Completion block
    internal typealias VAChoiceCompletionBlock  = (_ index: IndexPath, _ item: [Choice], _ isCrossTapped: Bool) -> Void

    // end

    // MARK: UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Call setup view
        self.setupView()
        // Add observer of for content size to get the height of the UITableView
        self.optionsTable.addObserver(self, forKeyPath: "contentSize", options: [], context: nil)
        self.crossImgView.image = UIImage(named: "crossIcon", in: Bundle(for: VAChoicePopupView.self), with: nil)
        self.crossImgView.tintColor = VAColorUtility.defaultButtonColor

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handleSessionExpiredState(notification:)),
            name: Notification.Name("sessionExpired"),
            object: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        self.optionsTable.removeObserver(self, forKeyPath: "contentSize")
        super.viewDidDisappear(animated)
    }
    // end

    // MARK: - Handle Session Expired State
    @objc func handleSessionExpiredState(notification: Notification) {
        /// Dismiss UIViewController
        self.dismiss(animated: false, completion: nil)
    }

    // MARK: - ObserveValue
    /// This function is used update the height of UITableViewController
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        let heightOfTableView = self.optionsTable.contentSize.height
        let heightOfScreen = self.view.bounds.height
        // If heightOfScreen is greater than height of tableview and 240 than height of tableview will vary on the basic of content else height of tablview will be fixed
        if heightOfScreen > (heightOfTableView - 240) {
            self.hTableViewConst.constant = self.optionsTable.contentSize.height
        } else {
            self.hTableViewConst.constant = (heightOfScreen - 240)
        }
    }

    // MARK: - SETUP VIEW
    /// This function is used to setupview
    func setupView() {
        self.titleLabel.text = LanguageManager.shared.localizedString(forKey: "More Options")
        self.titleLabel.font = UIFont(name: fontName, size: textFontSize)
        self.confirmButton.titleLabel?.font = UIFont(name: fontName, size: textFontSize)
        self.bgView.backgroundColor = VAColorUtility.receiverBubbleColor
        self.titleLabel.textColor = VAColorUtility.receiverBubbleTextIconColor
        self.confirmButton.setTitleColor(VAColorUtility.defaultThemeTextIconColor, for: .normal)
        self.seperatorTitleView.isHidden = true
        self.seperatorConfirmView.isHidden = true
        self.confirmButton.setTitle("\(self.confirmStaticText) (0)", for: .normal)
        self.confirmButton.layer.cornerRadius = 4
        self.confirmButton.backgroundColor = VAColorUtility.receiverBubbleColor
        self.confirmView.backgroundColor = VAColorUtility.defaultThemeTextIconColor
        self.titleView.backgroundColor = VAColorUtility.defaultThemeTextIconColor
    }

    /// - Parameters:
    ///   - arrayOfData: Array of Choice
    ///   - isMultiSelect: Bool (is multiple selction allowed)
    ///   - selectedIndexPath: IndexPath (already selected IndexPath from pervious screens)
    ///   - viewController: UIViewController
    ///   - completionHandler: VAChoiceCompletionBlock
    class func openPopupListView(arrayOfData: [Choice], isMultiSelect: Bool, selectedIndexPath: IndexPath,
                                 viewController: UIViewController, fontName: String, textFontSize: Double,
                                 completionHandler: @escaping VAChoiceCompletionBlock) {
        let story = UIStoryboard(name: "Main", bundle: Bundle(for: VAChoicePopupView.self))
        var alert: VAChoicePopupView!
        if #available(iOS 13, *) {
            alert = story.instantiateViewController(identifier: "VAChoicePopupView") as? VAChoicePopupView
        } else {
            alert = story.instantiateViewController(withIdentifier: "VAChoicePopupView") as? VAChoicePopupView
        }
        alert.completionBlock = completionHandler
        alert.openPopupListView(arrayOfData: arrayOfData,
                                isMultiSelect: isMultiSelect,
                                selectedIndexPath: selectedIndexPath,
                                viewController: viewController,
                                fontName: fontName,
                                textFontSize: textFontSize,
                                completionHandler: completionHandler)
    }

    /// - Parameters:
    ///   - arrayOfData: Array of Choice
    ///   - isMultiSelect: Bool (is multiple selction allowed)
    ///   - selectedIndexPath: IndexPath (already selected IndexPath from pervious screens)
    ///   - viewController: UIViewController
    ///   - completionHandler: VAChoiceCompletionBlock
    private func openPopupListView(arrayOfData: [Choice], isMultiSelect: Bool, selectedIndexPath: IndexPath, 
                                   viewController: UIViewController, fontName: String, textFontSize: Double,
                                   completionHandler: @escaping VAChoiceCompletionBlock) {
        self.indexPath = selectedIndexPath
        self.isMultiSelect = isMultiSelect
        self.arrayOfData = arrayOfData
        self.fontName = fontName
        self.textFontSize = textFontSize
        /// Set the height of the view on the basic of content
        if self.arrayOfData.count > 5 { // if greater then 5 then fixed height
            self.preferredContentSize = CGSize(width: 200, height: 200)
        } else { // height will vary on number of the array data
            self.preferredContentSize = CGSize(width: 200, height: 40 * self.arrayOfData.count)
        }
        self.modalPresentationStyle = .overCurrentContext
        /// Present viewcontroller
        viewController.present(self, animated: false) {
            /// check for selected items and update the confirm button
            let filterArray = self.arrayOfData.filter { obj in
                if obj.isSelected == true {
                    return true
                } else {
                    return false
                }
            }
            self.titleLabel.font = UIFont(name: fontName, size: textFontSize)
            self.confirmButton.titleLabel?.font = UIFont(name: fontName, size: textFontSize)
            if filterArray.count > 0 { // If selected array count greater than 0 then show total selected item on confirm button and update UI
                self.confirmButton.setTitleColor(VAColorUtility.receiverBubbleTextIconColor, for: .normal)
                self.confirmButton.setTitle("\(self.confirmStaticText) (\(filterArray.count))", for: .normal)
            } else { // If selected array count is equal to 0 then update UI of confirm button
                self.confirmButton.setTitleColor(VAColorUtility.defaultThemeTextIconColor, for: .normal)
                self.confirmButton.setTitle("\(self.confirmStaticText) (0)", for: .normal)
            }
            // Check for multiple selectection allowed
            if self.isMultiSelect { // if yes, then change the UI
                self.bgView.backgroundColor = VAColorUtility.receiverBubbleColor
                // Show confirm button
                self.hConfirmButtonConst.constant = 60
                // change background color
                self.confirmButton.backgroundColor = VAColorUtility.receiverBubbleColor
            } else {
                // Hide confirm button
                self.hConfirmButtonConst.constant = 0
                // change background color
                self.bgView.backgroundColor = VAColorUtility.defaultTextInputColor
                self.confirmButton.backgroundColor = VAColorUtility.defaultTextInputColor
            }
        }
    }

    // MARK: - IBActions
    /// This function is called when user tapped on cross button
    @IBAction func crossButtonTapped(_ sender: UIButton) {
        // Close the cuurent view
        self.dismiss(animated: false) {
            // Send data
            self.completionBlock(self.indexPath, self.arrayOfData, true)
        }
    }

    /// This funcyion is called when user tapped on confirm button
    @IBAction func confirmButtonTapped(_ sender: UIButton) {
        let filterArray = self.arrayOfData.filter { obj in
            if obj.isSelected == true {
                return true
            } else {
                return false
            }
        }
        if filterArray.count > 0 {
            // Close the cuurent view
            self.dismiss(animated: false) {
                // Send data
                self.completionBlock(self.indexPath, self.arrayOfData, false)
            }
        } else { }
    }
    // end
}

// MARK: - VAChoicePopupView extension for UITableViewController
extension VAChoicePopupView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayOfData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell: ChoiceCardOptionCell = tableView.dequeueReusableCell(withIdentifier: ChoiceCardOptionCell.identifier, for: indexPath) as? ChoiceCardOptionCell {
            if self.isMultiSelect {
                cell.configure(title: self.arrayOfData[indexPath.row].label, isMultiSelect: self.isMultiSelect, isSelect: self.arrayOfData[indexPath.row].isSelected, isFromPopup: false)
            } else {
                cell.configure(title: self.arrayOfData[indexPath.row].label, isMultiSelect: self.isMultiSelect, isSelect: self.arrayOfData[indexPath.row].isSelected, isFromPopup: true)
            }
            cell.titleLabel.font = UIFont(name: fontName, size: textFontSize)
            cell.checkboxButton.tag = indexPath.row
            cell.checkboxButton.addTarget(self, action: #selector(checkboxTapped(sender:)), for: .touchUpInside)
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.updateChoiceArrayOnSelection(index: indexPath.row)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }

    /// This function is called when user tapped on checkbox of an item
    @objc func checkboxTapped(sender: UIButton) {
        self.updateChoiceArrayOnSelection(index: sender.tag)
    }

    // MARK: - Update Choice Array
    /// This function is used to update Choice array on selection
    /// - Parameter index: Integer
    private func updateChoiceArrayOnSelection(index: Int) {
        var choice: Choice = self.arrayOfData[index]
        // handle choice as checkbox
        if choice.isSelected {
            choice.isSelected = false
        } else {
            choice.isSelected = true
        }
        self.arrayOfData[index] = choice
        let filterArray = self.arrayOfData.filter { obj in
            if obj.isSelected == true {
                return true
            } else {
                return false
            }
        }
        // Update confirm button on selection
        if filterArray.count > 0 {
            self.confirmButton.setTitleColor(VAColorUtility.receiverBubbleTextIconColor, for: .normal)
            self.confirmButton.setTitle("\(self.confirmStaticText) (\(filterArray.count))", for: .normal)
        } else {
            self.confirmButton.setTitleColor(VAColorUtility.defaultThemeTextIconColor, for: .normal)
            self.confirmButton.setTitle("\(self.confirmStaticText) (0)", for: .normal)
        }
        self.optionsTable.reloadData()
        // if multiple selected is not allowed then dismiss the popup on single selection
        if self.isMultiSelect == false {
            // dismiss popup
            self.dismiss(animated: false) {
                // call comletion block and send data to presentor view
                self.completionBlock(self.indexPath, self.arrayOfData, false)
            }
        }
    }
}
