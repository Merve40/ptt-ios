//
//  ViewController.swift
//  ptt
//
//  Created by Merve Sahin on 24.08.19.
//  Copyright © 2019 Yilmazgroup. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler{

    
    @IBOutlet var containerView: UIView!
    var webView:WKWebView!
    
    let eventNames = ["start", "stop"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //let url:URL! = URL(string: "https://ptt-demo.herokuapp.com")
        
        let html = Bundle.main.path(forResource: "index", ofType: "html")
        let url = URL(fileURLWithPath: html!)
        let request = URLRequest(url: url)
        
        webView.load(request)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

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
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("hello")
        if let contentBody = message.body as? String {
            if message.name == "start"{
                print("called start with callback = "+contentBody)
            }else if message.name == "stop"{
                print("called stop")
            }
        }
    }
    
}

