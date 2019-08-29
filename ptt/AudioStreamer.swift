//
//  AudioStreamer.swift
//  ptt
//
//  Created by Merve Sahin on 26.08.19.
//  Copyright © 2019 Yilmazgroup. All rights reserved.
//

import Foundation
import AVFoundation
import WebKit

class AudioStreamer: NSObject, AVCaptureAudioDataOutputSampleBufferDelegate {
    
    let captureSession = AVCaptureSession()
    let output = AVCaptureAudioDataOutput()
    var webView:WKWebView!
    var callback:String
    
    init(forWebView web:WKWebView ){
        webView = web
        callback = ""
        super.init()
        
        guard let audioDevice = AVCaptureDevice.default(for: .audio) else {return}
        
        do {
            try audioDevice.lockForConfiguration()
            let audioInput = try AVCaptureDeviceInput(device: audioDevice)
            audioDevice.unlockForConfiguration()
            
            if captureSession.canAddInput(audioInput){
                captureSession.addInput(audioInput)
            }
            
            if captureSession.canAddOutput(output) {
                let queue = DispatchQueue(label: "AudioSessionQueue")
                output.setSampleBufferDelegate(self, queue: queue)
                captureSession.addOutput(output)
            }
            
        }catch{
            print("failed to fetch audio device!")
        }
        
    }
    
    /*
     Triggered whenever raw audio data is available from the microphone.
     */
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        print("captured audio!")
        
        //TODO: convert CMSampleBuffer into AudioBuffer (or byte array) and send it as json-string to javascript code
        
        var jsonArrayString = ""
        let script = callback+"('"+jsonArrayString+"');"
        webView.evaluateJavaScript(script, completionHandler: nil)
    }
    
    func start(cb:String){
        callback = cb
        if !captureSession.isRunning {
            captureSession.startRunning()
            print("started recording")
        }
    }
    
    func stop(){
        if captureSession.isRunning{
            captureSession.stopRunning()
            print("stopped recording")
        }
    }
    
}
