// VAImageViewerVC.swift
// Copyright © 2021 Telus International. All rights reserved.

import UIKit

class VAImageViewerVC: UIViewController {

    // MARK: Outlet Declaration
    @IBOutlet weak var imageCollection: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var closeButton: UIButton!

    // MARK: Property Declaration
    var images: [String] = []
    var image: UIImage?
    var selectedImageIndex: Int = 0
    var isScrolledInitially: Bool = false
    var imageContentMode: UIView.ContentMode = .scaleAspectFit
    // end

    // MARK: View controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpCollectionVeiw()
        self.setPageIndicator()
        self.closeButton.setTitle("", for: .normal)
        self.closeButton.tintColor = VAColorUtility.defaultButtonColor
        self.closeButton.imageView?.layer.transform = CATransform3DMakeScale(0.95, 0.95, 0.95)
        DispatchQueue.main.asyncAfter(deadline: .now()+0.01) {
            self.imageCollection.isPagingEnabled = false
            self.imageCollection.scrollToItem(at: IndexPath(item: self.selectedImageIndex, section: 0), at: .left, animated: false)
            self.imageCollection.isPagingEnabled = true
        }
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handleSessionExpiredState(notification:)),
            name: Notification.Name("sessionExpired"),
            object: nil)
        self.overrideUserInterfaceStyle = .light
    }
    // end

    // MARK: - Handle Session Expired State
    @objc func handleSessionExpiredState(notification: Notification) {
        /// Dismiss UIViewController
        if self.navigationController == nil || self.navigationController?.viewControllers.first == self {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: false)
        }
    }

    // MARK: Set up UICollectionView
    /// This function is used to set up the UICollectionView with cell, confirm the delegate and datasource
    func setUpCollectionVeiw() {
        self.view.layoutIfNeeded()
        imageCollection.register(UINib(nibName: ImageViewerCell.nibName, bundle: Bundle(for: VAImageViewerVC.self)), forCellWithReuseIdentifier: ImageViewerCell.identifier)
        if let layout = imageCollection.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: imageCollection.bounds.width, height: imageCollection.bounds.height)
        }
        imageCollection.delegate = self
        imageCollection.dataSource = self
        imageCollection.reloadData()
    }
    // end

    // MARK: - Set Page Indicator
    /// This function is used to set the page indicator (dots) for pagination
    func setPageIndicator() {
        if images.count > 0 {
            pageControl.numberOfPages = images.count
            pageControl.currentPage = selectedImageIndex
            pageControl.currentPageIndicatorTintColor = VAColorUtility.defaultButtonColor
            pageControl.tintColor = .lightGray
            pageControl.pageIndicatorTintColor = .lightGray
        }
    }
    // end

    // MARK: Button Actions
    /// This function is used when user tapped on close button
    @IBAction func closeTapped(_ sender: Any) {
        if self.navigationController == nil || self.navigationController?.viewControllers.first == self {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: false)
        }
    }

}
// end

// MARK: UICollectionViewDelegate & UICollectionViewDataSource
extension VAImageViewerVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count == 0 ? 1 : images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell: ImageViewerCell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageViewerCell.identifier, for: indexPath) as? ImageViewerCell {
            cell.imageContentMode = imageContentMode
            if images.count == 0 {
                cell.configure(imageURL: "", image: image)
            } else {
                cell.configure(imageURL: images[indexPath.item], image: nil)
            }
            return cell
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? ImageViewerCell {
            cell.scrollView.zoomScale = 1
        }
    }
}
// end

// MARK: Scroll View Delegate
extension VAImageViewerVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // To set current page indicator in page control
        let xPoint = scrollView.contentOffset.x + scrollView.frame.width / 2
        let yPoint = scrollView.frame.height / 2
        let center = CGPoint(x: xPoint, y: yPoint)
        if let indexPath = imageCollection.indexPathForItem(at: center) {
            self.pageControl.currentPage = indexPath.row
        }
    }
}
// end
