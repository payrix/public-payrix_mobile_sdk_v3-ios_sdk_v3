//
//  UpdateBBPos.swift
//  ConfigUpdate2
//
//  Created by Prakash Katwal on 27/10/2021.
//

import UIKit
import PayrixSDK

class DemoUpdate: UIViewController
{
  
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
  @IBOutlet weak var lblCurrentVersionConfig: UILabel!
  @IBOutlet weak var lbllatestVersionConfig: UILabel!
  @IBOutlet weak var btnUpdateConfig: UIButton!
  @IBOutlet weak var lblRecommendedConfig: UILabel!
  
  @IBOutlet weak var lblCurrentVersionFirmware: UILabel!
  @IBOutlet weak var lbllatestVersionFirmware: UILabel!
  @IBOutlet weak var btnUpdateFirmware: UIButton!
  @IBOutlet weak var lblRecommendedFirmware: UILabel!
  
  @IBOutlet weak var lblCurrentVersionKeyInjection: UILabel!
  @IBOutlet weak var lbllatestVersionKeyInjection: UILabel!
  @IBOutlet weak var btnUpdateKeyInjection: UIButton!
  @IBOutlet weak var lblRecommendedKeyInjection: UILabel!
  
  
  var deviceDetails : [String : Any] = [:]
  let payrixSDK = PayrixSDKMaster.sharedInstance
  let payrixOTA = PayrixOTA.sharedInstance
  let sharedUtils = SharedUtilities.init()
  
  //the item app will update for ex- config, firmware or encryptionKey
  var updatingItem : OTAUpdateItem!
  
  // All the UI stuff to show name on labels has to done using otaConfigData
  var otaConfigData : PayrixOTAConfigData!
  //All the actual data pass for updating OTA features must be done using bbPOSConfigData
  var bbPOSConfigData : PayrixOTAConfigData!
  
  //    //setting the Device Setting version fecthed from API
  //    var latestDeviceSettingVersion : String = ""
  //    //setting the Device Firmware version fecthed from API
  //    var latestFirmwareVersion : String = ""
  //    //setting the Device Terminal version fecthed from API
  //    var latestTerminalSettingVersion : String = ""
  //    //setting the Encryption Key fecthed from API
  //    var latestEncryptionKey : String = ""
  //setting the Device Settings version fecthed from API
  var currentDeviceSettingVersion : String = ""
  //setting the Device Firmware version fecthed from API
  var currentFirmwareVersion : String = ""
  //setting the Device Terminal Settings version fecthed from API
  var currentTerminalSettingVersion : String = ""
  //setting the Encryption Key fecthed from Device Details
  var currentEncryptionKey : String = ""
  
  let configInfo = "The Configuration is a set of parameters that reside on the bbPOS device that specifies the requirements that Payrix has when performing transactions.  A example is the maximum transaction limit when using such a device.  This and many more make up the device configuration."
  let firmwareInfo = "Firmware is special hardware related software that is managed by the hardware manufacturer (bbPOS).  Occasionally the hardware manufacturer has minor fixes or enhancements that allow the device to perform better or to meet a specific regulatory requirement."
  let encryptionInfo = "The payment device reader is a highly secured device.  Part of that is due to the use of encryption keys.  When working with Payrix there are basically 2 types of keys.  A Sandbox Key which is used for testing in the Payrix Sandbox environment, and a Live Production Key for use by merchants performing transactions on Payrix's Live Production platform."
  
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    payrixOTA.doOTAStartup()
    payrixOTA.delegate = self
    
    setUpVersionLabels()
    //        setUpBatteryStatusInfo()
    payrixOTA.doGetTargetVersion()
  }
  
  func enableButtons(enable : Bool)
  {
    btnUpdateConfig.isEnabled = enable
    btnUpdateFirmware.isEnabled = enable
    btnUpdateKeyInjection.isEnabled = enable
  }
  //Updating UI with the info avilable for current and target settings
  func setUpVersionLabels()
  {
    currentFirmwareVersion = deviceDetails["firmwareVersion"] as? String ?? ""
    lblCurrentVersionFirmware.text = "Current Version" + ": \(currentFirmwareVersion)"
    
    currentDeviceSettingVersion = deviceDetails["deviceSettingVersion"] as? String ?? ""
    currentTerminalSettingVersion = deviceDetails["terminalSettingVersion"] as? String ?? ""
    lblCurrentVersionConfig.text = "Current Version" + ": \(currentTerminalSettingVersion)"
    
    currentEncryptionKey = deviceDetails["PayrixCurrentKeyProfileName"] as? String ?? ""
    lblCurrentVersionKeyInjection.text = "Current Version" + ": \(currentEncryptionKey)"
    
    self.title = deviceDetails["serialNumber"] as? String ?? ""
  }
    
  //fetching the details of device
  func doGetDeviceDetails()
  {
    payrixSDK.delegate = self
    payrixSDK.doGetDeviceInfo()
  }
  //Fetch the latest version of OTA update available
  func doGetOTAVersions()
  {
    payrixOTA.delegate = self
    payrixOTA.doGetTargetVersion()
  }
  
  
  
  func doHideUpdateConfig()
  {
    if (currentTerminalSettingVersion == otaConfigData.terminalSettingVersion) || otaConfigData.terminalSettingVersion.isEmpty
    //if (currentTerminalSettingVersion == latestTerminalSettingVersion) || latestTerminalSettingVersion.isEmpty
    {
      self.btnUpdateConfig.isHidden = true
      self.lblRecommendedConfig.isHidden = true
    }
    else
    {
      self.btnUpdateConfig.isHidden = false
      self.lblRecommendedConfig.isHidden = false
    }
  }
  
  func doHideUpdateFirmware()
  {
    if (currentFirmwareVersion == otaConfigData.firmwareVersion) || otaConfigData.firmwareVersion.isEmpty
    //if (currentFirmwareVersion == latestFirmwareVersion) || latestFirmwareVersion.isEmpty
    {
      self.btnUpdateFirmware.isHidden = true
      self.lblRecommendedFirmware.isHidden = true
    }
    else
    {
      self.btnUpdateFirmware.isHidden = true
      self.lblRecommendedFirmware.isHidden = true
    }
  }
  
  func doHideUpdateEncryptionKey()
  {
    if otaConfigData.encryptionKey.isEmpty || otaConfigData.encryptionKey == "Profile Not Supported by Payrix"
    //if latestEncryptionKey.isEmpty || latestEncryptionKey == "Profile Not Supported by Payrix"
    {
      self.btnUpdateKeyInjection.isHidden = true
      self.lblRecommendedKeyInjection.isHidden = true
    }
    else if currentEncryptionKey != otaConfigData.encryptionKey
    //else if currentEncryptionKey != latestEncryptionKey
    {
      self.btnUpdateKeyInjection.isHidden = false
      self.lblRecommendedKeyInjection.isHidden = false
      self.btnUpdateKeyInjection.setTitle("Update", for: .normal)
    }
    else
    {
      self.btnUpdateKeyInjection.isHidden = false
      self.lblRecommendedKeyInjection.isHidden = true
      self.btnUpdateKeyInjection.setTitle("Force Update", for: .normal)
    }
  }
  
  @IBAction func doShowConfigInfo(_ sender: Any)
  {
    sharedUtils.showMessage(theController: self, theTitle: "Configuration Version", theMessage: configInfo)
  }
  
  @IBAction func doShowFirmwareInfo(_ sender: Any)
  {
    sharedUtils.showMessage(theController: self, theTitle: "Firmware Version", theMessage: firmwareInfo)
  }
  
  @IBAction func doShowKeyInjectionInfo(_ sender: Any)
  {
    sharedUtils.showMessage(theController: self, theTitle: "Encrytpion Key Version", theMessage: encryptionInfo)
  }
  
  @IBAction func doUpdateConfig(_ sender: Any)
  {
    updatingItem = .config
    showAlertForUpdate()
  }
  
  @IBAction func doUpdateFirmware(_ sender: Any)
  {
    updatingItem = .firmware
    showAlertForUpdate()
  }
  
  @IBAction func doUpdateKeyInjection(_ sender: Any)
  {
    updatingItem = .encryptionKey
    showAlertForUpdate()
  }
  
  func showAlertForUpdate()
  {
    let alertC = UIAlertController(title: "Tap Confirm to continue and update", message: "", preferredStyle: .alert)
    let yesAction = UIAlertAction(title: "Confirm", style: .default) { action in
      self.performSegue(withIdentifier: "SegToProgress", sender: nil)
    }
    let noAction = UIAlertAction(title: "Cancel", style: .default) { action in
    }
    alertC.addAction(yesAction)
    alertC.addAction(noAction)
    present(alertC, animated: true, completion: nil)
  }
  
  
  @IBAction func actionBack(_ sender: Any)
  {
    self.navigationController?.popViewController(animated: true)
  }
  @IBAction func showDetail(_ sender: Any)
  {
    self.performSegue(withIdentifier: "segueDeviceDetail", sender: self)
  }
  
  func doAnimateIndicator(animate : Bool)
  {
    if animate
    {
      self.activityIndicator.startAnimating()
    }
    else
    {
      self.activityIndicator.stopAnimating()
    }
  }
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destination.
    // Pass the selected object to the new view controller.
    if segue.identifier == "segueDeviceDetail"
    {
      let destination : DemoDeviceDetailVC = segue.destination as! DemoDeviceDetailVC
      destination.deviceDetails = deviceDetails
    }
    else if segue.identifier == "SegToProgress"
    {
      let destination : DemoOTAProgress = segue.destination as! DemoOTAProgress
      destination.updateItem = updatingItem
      destination.bbPOSConfigData = self.bbPOSConfigData
      //            destination.latestEncryptionKey = latestEncryptionKey
      //            destination.latestFirmwareVersion = latestFirmwareVersion
      //            destination.latestDeviceSettingVersion = latestDeviceSettingVersion
      //            destination.latestTerminalSettingVersion  = latestTerminalSettingVersion
      destination.delegateOTACompleted = self
    }
  }
}


extension DemoUpdate : OTAUpdateDelegate
{
  
  func didReceiveTargetVersionResult(success: Bool, otaResult: BBDeviceOTAResult, passOTAConfigData: PayrixOTAConfigData!, passBBPOSConfigData: PayrixOTAConfigData!)
  //    func didReceiveTargetVersionResult(success: Bool, otaResult: BBDeviceOTAResult, otaData: [AnyHashable : Any]!)
  {
    //        print("didReceiveTargetVersionResult otaData : \(otaData) \n result: \(otaResult) \n isSuccess : \(success)")
    
    //        device details: ["isCharging": 0, "bootloaderVersion": 5.00.16.22, "batteryPercentage": 73, "isSupportedSoftwarePinPad": 0, "pinKsn": 88888827902615000004, "bID": CHB202927002615, "isUsbConnected": 0, "terminalSettingVersion": BBZZ_Generic_v25, "productID": 4348423230, "vendorID": 42425A5A, "macKsn": 88888827902615600001, "isSupportedTrack3": 0, "uid": 270041001947373439373230, "firmwareVersion": 1.00.03.47, "isSupportedNfc": 1, "serialNumber": CHB202927002615, "hardwareVersion": 1.0.4, "deviceSettingVersion": BBZZ_Generic_v25, "isSupportedTrack2": 1, "isSupportedTrack1": 1, "formatID": 60, "sdkVersion": 3.19.1, "trackKsn": 888888279026154001A5, "emvKsn": 88888827902615200209, "batteryLevel": 3.931]
    //
    //
    //        didReceiveTargetVersionResult otaData : Optional([AnyHashable("terminalSettingVersion"): PIZZ_Generic_v2, AnyHashable("deviceSettingVersion"): PIZZ_Generic_v2, AnyHashable("firmwareVersion"): 1.00.03.47, AnyHashable("keyProfileName"): Payrix MSR])
    
    self.doAnimateIndicator(animate: false)
    
    //        let otaDataDict = otaData as? [String : AnyObject] ?? [:]
    
    if otaResult == .failed
    //        if otaDataDict.isEmpty || otaResult == .failed
    {
      sharedUtils.showMessage(theController: self, theTitle: "Error", theMessage: "")
      return
    }
    
    
    //        latestDeviceSettingVersion  = otaDataDict["deviceSettingVersion"] as? String ?? ""
    //        latestTerminalSettingVersion = otaDataDict["terminalSettingVersion"] as? String ?? ""
    //
    otaConfigData = passOTAConfigData
    bbPOSConfigData = passBBPOSConfigData
    //      lbllatestVersionConfig.text = "Latest Payrix Version" + ": \(latestDeviceSettingVersion)"
    lbllatestVersionConfig.text = "Latest Payrix Version" + ": \(passOTAConfigData.deviceSettingVersion)"
    //
    //        latestFirmwareVersion = otaDataDict["firmwareVersion"] as? String ?? ""
    //        lbllatestVersionFirmware.text = "Latest Payrix Version" + ": \(latestFirmwareVersion)"
    lbllatestVersionFirmware.text = "Latest Payrix Version" + ": \(otaConfigData.firmwareVersion)"
    //
    //        latestEncryptionKey = otaDataDict["PayrixTargetKeyProfileName"] as? String ?? ""
    //        lbllatestVersionKeyInjection.text = "Latest Payrix Version" + ": \(latestEncryptionKey)"
    lbllatestVersionKeyInjection.text = "Latest Payrix Version" + ": \(otaConfigData.encryptionKey)"
    
    doHideUpdateConfig()
    doHideUpdateFirmware()
    doHideUpdateEncryptionKey()
    
  }
}

extension DemoUpdate : OTACompleteDelegate
{
  func otaCompleted(message : String, info : String)
  {
    sharedUtils.showMessage(theController: self, theTitle: message, theMessage: info)
    activityIndicator.startAnimating()
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5)
    {
      self.doGetDeviceDetails()
    }
  }
}
extension DemoUpdate : PayrixSDKDelegate
{
  func didReceiveOTADeviceData(deviceInfo: [AnyHashable : Any]!)
  {
    deviceDetails = deviceInfo as? [String : AnyObject] ?? [:]
    setUpVersionLabels()
    
    doHideUpdateConfig()
    doHideUpdateFirmware()
    doHideUpdateEncryptionKey()
    
    doGetOTAVersions()
  }
}
