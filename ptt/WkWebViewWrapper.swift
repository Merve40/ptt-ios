//
//  WkWebViewWrapper.swift
//  ptt
//
//  Created by Merve Sahin on 25.08.19.
//  Copyright © 2019 Yilmazgroup. All rights reserved.
//

import Foundation
import WebKit

class WkWebViewWrapper : NSObject, WKScriptMessageHandler{
    
    let eventNames = ["start", "stop"]
    var eventFunctions: Dictionary<String, (String) -> Void> = [:]
    let controller: WKUserContentController
    
    init(forWebView webViewConf : WKWebViewConfiguration){
        controller = WKUserContentController()
        webViewConf.userContentController = controller
        super.init()
        
        controller.add(self, name: "start")
        controller.add(self, name: "stop")
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
