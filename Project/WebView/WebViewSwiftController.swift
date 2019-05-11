//
//  WebViewSwiftController.swift
//  Universal
//
//  Created by Mark on 04/01/2019.
//  Copyright © 2019 Sherdle. All rights reserved.
//

import Foundation
import WebKit

let OFFLINE_FILE_EXTENSION = "html"
let HIDE_SHARE = true

class WebViewSwiftController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    
    
    @IBOutlet var webView: WKWebView!
    @IBOutlet weak var shareButton: UIBarButtonItem?
    @IBOutlet weak var backButton: UIBarButtonItem?
    @IBOutlet weak var forwardButton: UIBarButtonItem?
    
    var scrollCoordinator: JDFPeekabooCoordinator?
    @objc var params: [Any]?
    @objc var htmlString = ""
    @objc var basicMode = false
    var loadingIndicator: UIActivityIndicatorView?
    var refreshControl: UIRefreshControl?
    var connectionView: NoConnectionView?
    
    @IBOutlet weak var topMarginConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Note: Jumping in WebView is cause of WKWebView (issue does not occur with UIWebView) and can potentially be resolved by disabling the dynamically 'hiding navigation'
        
        if !(AppDelegate.lightTheme()) {
            loadingIndicator = UIActivityIndicatorView(style: .white)
        } else {
            loadingIndicator = UIActivityIndicatorView(style: .gray)
        }
        loadingIndicator!.startAnimating()
        navigationItem.titleView = loadingIndicator
        
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(self.handleRefresh(_:)), for: .valueChanged)
        webView.scrollView.addSubview(refreshControl!) //<- this is point to use. Add "scrollView" property.
        
        if basicMode {
            navigationItem.rightBarButtonItems = nil
            refreshControl!.isEnabled = false
        }
        
        if HIDE_SHARE {
            var toolbarButtons = navigationItem.rightBarButtonItems
            toolbarButtons?.removeAll(where: { element in element == shareButton })
            navigationItem.rightBarButtonItems = toolbarButtons
        }
        
        loadWebViewContent()
        
        //Hiding
        if (AppDelegate.hidingNavigation()) {
            let parent = navigationController as? TabNavigationController
            scrollCoordinator = JDFPeekabooCoordinator()
            scrollCoordinator!.scrollView = webView.scrollView
            scrollCoordinator!.topView = navigationController?.navigationBar
            scrollCoordinator!.topViewBackground = parent?.gradientView
            
            //TODO this was present in the ObjC version, but causes crash in Swift. Where is it for? Everything seems to work fine without.
            //scrollCoordinator!.topViewItems = [parent!.menuButton!, self.navigationController!.navigationItem.titleView! as! UIView, self.navigationController!.navigationItem.rightBarButtonItem?.value(forKey: "view")! as! UIView]

            topMarginConstraint.isActive = false
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func loadWebViewContent() {
        //Set all the data
        //If the url begins with http (or https for that matter), load it as a webpage. Otherwise, load an asset
        if (htmlString.count > 0) {
            webView.loadHTMLString(htmlString, baseURL: URL(string: params![0] as! String))
        } else {
            var url: URL?
            var urlString: String
            
            //If a string does not start with http, does end with .html and does not contain any slashes, we'll assume it's a local page.
            if !(((params![0] as? NSString)?.substring(to: 4)) == "http") && (params![0] as! String).contains(".\(OFFLINE_FILE_EXTENSION)") && !(params![0] as! String).contains("/") {
                urlString = (params![0] as! String).replacingOccurrences(of: ".\(OFFLINE_FILE_EXTENSION)", with: "")
                url = URL(fileURLWithPath: Bundle.main.path(forResource: urlString, ofType: OFFLINE_FILE_EXTENSION, inDirectory: "Local") ?? "")
            } else {
                if !(((params![0] as? NSString)?.substring(to: 4)) == "http") {
                    urlString = "http://\(params![0])"
                } else {
                    urlString = params![0] as! String
                }
                
                url = URL(string: urlString)
            }
            
            if let url = url {
                webView.load(URLRequest(url: url))
            }
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let app = UIApplication.shared
        let url: URL? = navigationAction.request.url
        
        if url?.absoluteString.contains("https://disqus.com/next/login-success/") ?? false {
            loadWebViewContent()
            decisionHandler(WKNavigationActionPolicy.cancel)
            return
        }
        
        if AppDelegate.targetBlankSafari() {
            if navigationAction.targetFrame == nil {
                if let url = url {
                    if app.canOpenURL(url) {
                        let application = UIApplication.shared
                        application.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                        decisionHandler(WKNavigationActionPolicy.cancel)
                        return
                    }
                }
            }
        }
        
        if (url?.absoluteString.starts(with: "file:") ?? false) {
            decisionHandler(WKNavigationActionPolicy.allow)
            return
        }
        
        if !(url?.scheme?.isEqual("http") ?? false) && !(url?.scheme?.isEqual("https") ?? false) {
            if let url = url {
                if app.canOpenURL(url) {
                    let application = UIApplication.shared
                    application.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                    decisionHandler(WKNavigationActionPolicy.cancel)
                    return
                }
            }
        }
        
        decisionHandler(WKNavigationActionPolicy.allow)
    }
    
    @IBAction func goForward(_ sender: Any?) {
        webView.goForward()
    }
    
    @IBAction func goBack(_ sender: Any?) {
        webView.goBack()
    }
    
    @IBAction func share(_ sender: Any) {
        let activityItems = [webView.url!.absoluteString]
        presentActions(activityItems, sender: sender)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        URLCache.shared.removeAllCachedResponses()
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        if !(refreshControl!.isRefreshing) {
            navigationItem.titleView = loadingIndicator
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        navigationItem.titleView = nil
        
        if refreshControl != nil && refreshControl!.isRefreshing {
            refreshControl!.endRefreshing()
        }
        
        // Enable or disable back button
        backButton?.isEnabled = webView.canGoBack
        
        // Enable or disable forward button
        forwardButton?.isEnabled = webView.canGoForward
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame?.isMainFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        if (error as NSError).code != NSURLErrorNotConnectedToInternet && (error as NSError).code != NSURLErrorNetworkConnectionLost {
            if !Reachability.connected() {
                update(forConnectivity: false)
            }
            //If the error is not a connection error, show a dialog
            //let alertController = UIAlertController(title: NSLocalizedString("error", comment: ""), message: NSLocalizedString("error_webview", comment: ""), preferredStyle: .alert)
            
            //let ok = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: nil)
            //alertController.addAction(ok)
            //present(alertController, animated: true)
            let error = String(format: "%@ code: %@", NSLocalizedString("error_webview", comment: ""), error.localizedDescription)
            print(error)
        } else {
            //If the error is a connection error, and this is the page the user is now interacting with. Show a no connectivity warning.
            update(forConnectivity: false)
        }
        
        self.webView(webView, didFinish: navigation)
        
    }
    
    func load(_ request: URLRequest) {
        if webView.isLoading {
            webView.stopLoading()
        }
        webView.load(request)
    }
    
    func viewWillDisappear() {
        if webView.isLoading {
            webView.stopLoading()
        }
    }
    
    //Selectors cannot pass parameters, therefore we offer this utility method
    @objc func updateForConnectivityFromScreen() {
        update(forConnectivity: true)
    }
    
    func update(forConnectivity calledFromButton: Bool) {
        
        if !Reachability.connected() {
            //If the no connection view is not already displayed
            if !(connectionView?.superview != nil) {
                connectionView = Bundle.main.loadNibNamed("NoConnectionView", owner: self, options: nil)?.last as? NoConnectionView
                connectionView!.frame = view.frame
                //_connectionView.label.text = @"Error";
                connectionView!.retryButton.addTarget(self, action: #selector(self.updateForConnectivityFromScreen), for: .touchUpInside)
                
                view.addSubview(connectionView!)
                view.bringSubviewToFront(connectionView!)
            }
        } else {
            //If the view is shown, remove it.
            if (connectionView?.superview != nil) {
                connectionView!.removeFromSuperview()
                connectionView = nil
            }
            if webView.url != nil {
                webView.reload()
            } else {
                loadWebViewContent()
            }
        }
        
    }
    
    @objc func handleRefresh(_ refresh: UIRefreshControl?) {
        // Reload my data
        webView.reload()
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
