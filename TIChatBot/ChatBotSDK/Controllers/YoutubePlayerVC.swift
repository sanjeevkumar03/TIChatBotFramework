// YoutubePlayerVC.swift
// Copyright © 2021 Telus International. All rights reserved.

import UIKit
import WebKit
import SDWebImage

class YoutubePlayerVC: UIViewController {

    // MARK: Outlet Declaration
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var viewNavigation: UIView!
    @IBOutlet weak var imgClose: UIImageView!
    @IBOutlet weak var viewHeaderSeperator: UIView!
    @IBOutlet weak var webViewObj: WKWebView!

    // MARK: Property Declaration
    var videoUrl: String = ""
    var youTubeVideoUrl: URL!
    var didLoadVideo = false
    var webView = WKWebView()

    // MARK: View controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        self.imgClose.tintColor = VAColorUtility.white
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
            self.configureWebView()
            // self.playVideoInIframe()
        })
    }

    // MARK: Custom Methods
    func configureWebView() {
        let webViewConfig = WKWebViewConfiguration()
        webViewConfig.allowsInlineMediaPlayback = true
        webViewConfig.mediaTypesRequiringUserActionForPlayback = []
        webViewConfig.allowsPictureInPictureMediaPlayback = true
        webViewConfig.preferences.javaScriptEnabled = true
        self.view.layoutIfNeeded()
        webView = WKWebView(frame: self.containerView.bounds, configuration: webViewConfig)
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = false
        webView.isOpaque = false
        webView.scrollView.backgroundColor = .black
        let videoID = Helper.getYouTubeVideoIdToPlayVideo(videoUrl: videoUrl)
        let url = "https://www.youtube.com/embed/\(videoID)?playsinline=1?autoplay=1"
        if let url = URL(string: url) {
            var youtubeRequest = URLRequest(url: url)
            youtubeRequest.setValue("https://www.youtube.com", forHTTPHeaderField: "Referer")
            webView.load(youtubeRequest)
            CustomLoader.show()
            containerView.addSubview(webView)
        }
    }
    func playVideoInIframe() {
        self.view.layoutIfNeeded()
        webViewObj.isHidden = false
        webViewObj.configuration.mediaTypesRequiringUserActionForPlayback = []
        let videoID = videoUrl.components(separatedBy: "=").last ?? ""
        let url = "https://www.youtube.com/embed/\(videoID)"
        if let url = URL(string: url) {
            youTubeVideoUrl = url
            if !didLoadVideo {
                webViewObj.loadHTMLString(embedVideoHtml, baseURL: nil)
                didLoadVideo = true
            }
        }
    }
    /*
     var playerVars: [String:Any] = [
                 "autoplay": 1,
                 "playsinline" : 1,
                 "enablejsapi": 1,
                 "wmode": "transparent",
                 "controls": 0,
                 "showinfo": 0,
                 "rel": 0,
                 "modestbranding": 1,
                 "iv_load_policy": 3 //annotations
             ]
     */
    var embedVideoHtml: String {
        return """
            <!DOCTYPE html>
            <html>
            <body>
            <!-- 1. The <iframe> (and video player) will replace this <div> tag. -->
            <div id="player"></div>

            <script>
            var tag = document.createElement('script');

            tag.src = "https://www.youtube.com/iframe_api";
            var firstScriptTag = document.getElementsByTagName('script')[0];
            firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

            var player;
            function onYouTubeIframeAPIReady() {
            player = new YT.Player('player', {
            playerVars: { 'autoplay': 1, 'controls': 0, 'playsinline': 1 },
            height: '\(webViewObj.frame.height)',
            width: '\(webViewObj.frame.width)',
            videoId: '\(youTubeVideoUrl.lastPathComponent)',
            events: {
            'onReady': onPlayerReady
            }
            });
            }

            function onPlayerReady(event) {
            event.target.playVideo();
            }
            </script>
            </body>
            </html>
            """
    }
    // MARK: Button Actions
    @IBAction func closeTapped(_ sender: Any) {
        // self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true)
    }
    // end
}

// MARK: WKNavigationDelegate
extension YoutubePlayerVC: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // Start Loader
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Stop leader
        CustomLoader.hide()
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        CustomLoader.hide()
        debugPrint(error.localizedDescription)
        let alert = UIAlertController.init(title: LanguageManager.shared.localizedString(forKey: "Error"),
                                           message: LanguageManager.shared.localizedString(forKey: "Unable to play video"),
                                           preferredStyle: .alert)
        let action = UIAlertAction.init(title: LanguageManager.shared.localizedString(forKey: "OK"), style: .default) { _ in

        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}
// end
