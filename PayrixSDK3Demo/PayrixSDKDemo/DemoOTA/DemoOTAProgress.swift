//
//  DemoOTAProgress.swift
//  PayrixSDKDemo
//
//  Created by PRAKASH KOtwal on 11/01/2022.
//  Copyright © 2022 Payrix. All rights reserved.
//

import UIKit
import PayrixSDK

enum OTAUpdateItem : String
{
    case config
    case firmware
    case encryptionKey
}

protocol OTACompleteDelegate : AnyObject
{
    func otaCompleted(message : String, info : String)
}

class DemoOTAProgress: UIViewController
{
    
    @IBOutlet weak var lblUpdateItem: UILabel!
    @IBOutlet weak var lblUpdateProgress: UILabel!
    @IBOutlet weak var updateProgress: UIProgressView!
    
    let otaUpdate = PayrixOTA.sharedInstance
    let sharedUtils = SharedUtilities.init()
    
    var latestDeviceSettingVersion : String = ""
    var latestFirmwareVersion : String = ""
    var latestTerminalSettingVersion : String = ""
    var latestEncryptionKey : String = ""
    
    var updateItem : OTAUpdateItem!
    var delegateOTACompleted : OTACompleteDelegate!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
            
        otaUpdate.delegate = self
        if updateItem == .config
        {
            self.doUpdateConfig()
        }
        else if updateItem == .firmware
        {
//            self.dummyCodeForFirmware()
            self.doUpdateFirmware()
        }
        else if updateItem == .encryptionKey
        {
            self.doUpdateKeyInjection()
        }
        updateLabelWithPrecentage(percentUpdate: 0)
    }
    
//    var lastPercent = 0.0
//    func dummyCodeForFirmware()
//    {
//        var timer = Timer()
//
//            //in a function or viewDidLoad()
//        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
//
//
//    }
    
    
    //new function
//    @objc func timerAction()
//    {
//        lastPercent += 10
//        updateLabelWithPrecentage(percentUpdate: Float(lastPercent))
//    }
    
    func updateLabelWithPrecentage(percentUpdate : Float)
    {
        updateProgress.progress = percentUpdate/100
        if updateItem == .config
        {
            lblUpdateItem.text = "Updating Configuration"
        }
        else if updateItem == .firmware
        {
            lblUpdateItem.text = "Updating Firmware"
        }
        else if updateItem == .encryptionKey
        {
            lblUpdateItem.text = "Updating Encryption Key"
        }
        else
        {
            self.lblUpdateItem.text = "Updating..."
            self.dismiss(animated: true, completion: nil)
        }
        lblUpdateProgress.text = " \(percentUpdate)%"
    }
    
    func doUpdateConfig()
    {
        otaUpdate.doOTAConfigUpdate(deviceSettingVersion: latestDeviceSettingVersion, terminalSettingVersion: latestTerminalSettingVersion)
    }
    
    func doUpdateFirmware()
    {
        otaUpdate.doOTAFirmwareUpdate(firmwareVersion: latestFirmwareVersion)
    }
    
    func doUpdateKeyInjection()
    {
        otaUpdate.doOTAKeyInjection(keyProfile: latestEncryptionKey)
    }
    
    
    func showAlert(title : String, message : String)
    {
        self.dismiss(animated: true) {
            self.delegateOTACompleted.otaCompleted(message: title, info: message)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension DemoOTAProgress : OTAUpdateDelegate
{
    func didReceiveRemoteFirmwareUpdate(success: Bool, otaResult: BBDeviceOTAResult, otaMessage: String!)
    {
        print("didReceiveRemoteFirmwareUpdate message : \(otaMessage) \n result: \(otaResult) \n isSuccess : \(success)")
        if success
        {
            self.showAlert(title: "Firmware Updated successfully.", message: "")
        }
        else
        {
            self.showAlert(title: "Firmware NOT Updated.", message: otaMessage)
        }
        
    }
    
    func didReceiveRemoteConfigUpdate(success: Bool, otaResult: BBDeviceOTAResult, otaMessage: String!)
    {
        if success
        {
            self.showAlert(title: "Configuration Updated successfully.", message: "")
        }
        else
        {
            self.showAlert(title: "Configuration NOT Updated.", message: otaMessage)
        }
        
        print("didReceiveRemoteConfigUpdate message : \(otaMessage) \n result: \(otaResult) \n isSuccess : \(success)")
    }
    
    
    func didReceiveRemoteKeyInjectionResult(success: Bool, otaResult: BBDeviceOTAResult, otaMessage: String!)
    {
        
            if success
            {
                self.showAlert(title: "Encryption Key Updated successfully.", message: "")
            }
            else
            {
                self.showAlert(title: "Encryption Key NOT Updated.", message: otaMessage)
            }
            
            print("didReceiveRemoteKeyInjectionResult message : \(otaMessage) \n result: \(otaResult) \n isSuccess : \(success)")
        
    }
    
    func didReceiveOTAProgress(percentProgress: Float)
    {
        print("didReceiveOTAProgress percentage : \(percentProgress)")
        self.updateLabelWithPrecentage(percentUpdate: percentProgress)
    }
    
    //Not needed delegates
    
    func didReceiveOTAConnectResults(success: Bool!, theDevice: String!)
    {
        print("didReceiveOTAConnectResults thedevice : \(theDevice) \n isSuccess : \(success)")
    }
    
    func didReceiveOTADisconnectResults(success: Bool!)
    {
        print("didReceiveOTADisconnectResults : \(success)")
        
    }
    func didReceiveOTAScanResults(success: Bool!, scanMsg: String!, payDevices: [AnyObject]?)
    {
        print("didReceiveOTAScanResults scanMsg : \(scanMsg) \n payDevices: \(payDevices) \n isSuccess : \(success)")
    }
    
    
    func didReceiveLocalFirmwareUpdate(success: Bool, otaResult: BBDeviceOTAResult, otaMessage: String!) {
        
    }
    
    func didReceiveLocalConfigUpdate(success: Bool, otaResult: BBDeviceOTAResult, otaMessage: String!) {
        
    }
    
    func didReceiveTargetVersionResult(success: Bool, otaResult: BBDeviceOTAResult, otaData: [AnyHashable : Any]!) {
        
    }
    
    func didReceiveSetTargetVersionResult(success: Bool, otaResult: BBDeviceOTAResult, otaMessage: String!) {
        
    }
    
    func didReceiveTargetVersionListResult(success: Bool, otaResult: BBDeviceOTAResult, otaList: [Any]!, otaMessage: String!) {
        
    }
}
