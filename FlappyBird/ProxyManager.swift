//
//  ProxyManager.swift
//  FlappyBird
//
//  Created by Mac on 8/8/18.
//  Copyright © 2018 Fullstack.io. All rights reserved.
//

import UIKit
import SmartDeviceLink

class ProxyManager: NSObject {
    private let appName:String = Keys.sdlAppName.value
    private let appID:String = Keys.sdlAppID.value
    private let shortAppName:String = Keys.sdlAppName.value
    private let appType:SDLAppHMIType = .navigation
    public var isConnected:Bool = false
    private var firstHMIFull:Bool = false
    private var latestHMILevel:SDLHMILevel = .none
    
    //viewcontroller to send to hmi
    var _sdlVC:UIViewController?
    var sdlViewController: UIViewController {
        get {
            if _sdlVC == nil {
                return UIViewController()
            }
            return _sdlVC!
        }
        set {
            _sdlVC = newValue
            sdlManager.streamManager?.rootViewController = newValue
        }
    }
    
    private var sdlManager:SDLManager!
    static let sharedManager = ProxyManager() //Singleton
    
    override init() {
        super.init()
        self.setupManager()
       
    }
    private func setupManager(){
        let lifecycleConfiguration = SDLLifecycleConfiguration(appName: self.appName, appId: self.appID)
        let appIcon = SDLArtwork(image: #imageLiteral(resourceName: "flap"), name: "Flappy", persistent: true, as: .PNG)
        lifecycleConfiguration.appIcon = appIcon
        lifecycleConfiguration.shortAppName = self.shortAppName
        lifecycleConfiguration.appType = self.appType

        let streamingConfig = SDLStreamingMediaConfiguration(securityManagers: [FMCSecurityManager.self], encryptionFlag: SDLStreamingEncryptionFlag.none, videoSettings: nil, dataSource: nil, rootViewController: self.sdlViewController)
        streamingConfig.carWindowRenderingType = .viewBeforeScreenUpdates
        
        let logConfig = SDLLogConfiguration.debug()
        logConfig.globalLogLevel = .debug

        let configuration = SDLConfiguration(lifecycle: lifecycleConfiguration, lockScreen: nil , logging: logConfig , streamingMedia: streamingConfig)
        
        sdlManager = SDLManager(configuration: configuration, delegate: self)
    }
    
    public func connect(){
        sdlManager.start(readyHandler: {(success,error) in
            if success {
                self.isConnected = true
            }
        })
    }
    
    public func disconnect() {
        sdlManager.stop()
    }
    
    func cycleProxy() {
        if isConnected {
            self.disconnect()
        }
        self.setupManager()
        self.connect()
    }
}

extension ProxyManager:SDLManagerDelegate{
    func managerDidDisconnect() {
        self.isConnected = false
    }
    
    func hmiLevel(_ oldLevel: SDLHMILevel, didChangeToLevel newLevel: SDLHMILevel) {
        // On our first HMI level that isn't none, do some setup
        if newLevel != .none && latestHMILevel == .none {
            // This is our first time in a non-NONE state
            self.latestHMILevel = newLevel
            print("first state \(newLevel)")
            
        }
        
        // HMI state is changing from NONE or BACKGROUND to FULL or LIMITED
        if (newLevel == .full && !firstHMIFull) {
            // This is our first time in a FULL state
            self.firstHMIFull = true
        }
        
        if (newLevel == .full ) {
            // We entered full
            print("entered HMI full")
        }
    }
    
    
}
