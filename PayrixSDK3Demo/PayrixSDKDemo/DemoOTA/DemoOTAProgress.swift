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
  
  //    var latestDeviceSettingVersion : String = ""
  //    var latestFirmwareVersion : String = ""
  //    var latestTerminalSettingVersion : String = ""
  //    var latestEncryptionKey : String = ""
  var bbPOSConfigData : PayrixOTAConfigData!
  
  var updateItem : OTAUpdateItem!
  var delegateOTACompleted : OTACompleteDelegate!
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    otaUpdate.delegate = self
    if updateItem == .config
    {
      lblUpdateItem.text = "Updating Configuration"
      self.doUpdateConfig()
    }
    else if updateItem == .firmware
    {
      lblUpdateItem.text = "Updating Firmware"
      self.doUpdateFirmware()
    }
    else if updateItem == .encryptionKey
    {
      lblUpdateItem.text = "Updating Encryption Key"
      self.doUpdateKeyInjection()
    }
    else
    {
      self.lblUpdateItem.text = "Updating" + "..."
      self.dismiss(animated: true, completion: nil)
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
    let progressValue = percentUpdate/100
    updateProgress.progress = progressValue
    let percentString = String(format: "%.1f", (progressValue * 100))
    lblUpdateProgress.text = "\(percentString) %"
  }
  
  func doUpdateConfig()
  {
    otaUpdate.doOTAConfigUpdate(deviceSettingVersion: bbPOSConfigData.deviceSettingVersion, terminalSettingVersion: bbPOSConfigData.terminalSettingVersion)
    //        otaUpdate.doOTAConfigUpdate(deviceSettingVersion: latestDeviceSettingVersion, terminalSettingVersion: latestTerminalSettingVersion)
  }
  
  func doUpdateFirmware()
  {
    otaUpdate.doOTAFirmwareUpdate(firmwareVersion: bbPOSConfigData.firmwareVersion)
    //        otaUpdate.doOTAFirmwareUpdate(firmwareVersion: latestFirmwareVersion)
  }
  
  func doUpdateKeyInjection()
  {
    otaUpdate.doOTAKeyInjection(keyProfile: bbPOSConfigData.encryptionKey)
    //        otaUpdate.doOTAKeyInjection(keyProfile: latestEncryptionKey)
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
}
