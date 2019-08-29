//
//  ViewController.swift
//  ptt
//
//  Created by Merve Sahin on 24.08.19.
//  Copyright © 2019 Yilmazgroup. All rights reserved.
//

import UIKit
import WebKit
import AVFoundation

class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler{

    
    var webView:WKWebView!
    var audioStreamer:AudioStreamer!
    
    let eventNames = ["start", "stop"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        //let url:URL! = URL(string: "https://ptt-demo.herokuapp.com")
        let html = Bundle.main.path(forResource: "index", ofType: "html")
        let url = URL(fileURLWithPath: html!)
        let request = URLRequest(url: url)
        
        webView.load(request)
        audioStreamer = AudioStreamer(forWebView: webView)
    }
    
    override func loadView() {
        
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        
        let contentController = WKUserContentController()
        contentController.add(self, name: "start")
        contentController.add(self, name: "stop")
        configuration.userContentController = contentController
        
        webView = WKWebView(frame: .zero, configuration: configuration)
        
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        view = webView
    }
    

    /*
     Utility method for handling methods in WebView
     */
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        
        guard let response = navigationResponse.response as? HTTPURLResponse,
            let url = navigationResponse.response.url else {
                decisionHandler(.allow)
                return
        }
        
        if let headerFields = response.allHeaderFields as? [String: String] {
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: url)
            cookies.forEach { cookie in
                webView.configuration.websiteDataStore.httpCookieStore.setCookie(cookie)
            }
        }
        
        decisionHandler(.allow)
    }
    
    /*
     This method is triggered from javascript (see api.js)
     */
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let callback = message.body as? String {
            if message.name == "start"{ // start recording audio
                print("called start with callback = "+callback)
                
                audioStreamer.start(cb: callback)
                
            }else if message.name == "stop"{ // stop recording audio
                print("called stop")
                
                audioStreamer.stop()
            }
        }
    }
    
}

