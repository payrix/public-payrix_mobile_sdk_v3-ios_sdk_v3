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
    
    let otaUpdate = PayrixOTA.sharedInstance
    let sharedUtils = SharedUtilities.init()
    var updatingItem : OTAUpdateItem!
    
    var latestDeviceSettingVersion : String = ""
    var latestFirmwareVersion : String = ""
    var latestTerminalSettingVersion : String = ""
    var latestEncryptionKey : String = ""
    
    var currentDeviceSettingVersion : String = ""
    var currentFirmwareVersion : String = ""
    var currentTerminalSettingVersion : String = ""
    var currentEncryptionKey : String = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        currentFirmwareVersion = deviceDetails["firmwareVersion"] as? String ?? ""
        lblCurrentVersionFirmware.text = "Current Version: \(currentFirmwareVersion)"
        
        currentDeviceSettingVersion = deviceDetails["deviceSettingVersion"] as? String ?? ""
        currentTerminalSettingVersion = deviceDetails["terminalSettingVersion"] as? String ?? ""
        lblCurrentVersionConfig.text = "Current Version: \(currentTerminalSettingVersion)"
        
        
        currentEncryptionKey = deviceDetails["PayrixCurrentKeyProfileName"] as? String ?? ""
        lblCurrentVersionKeyInjection.text = "Current Version: \(currentEncryptionKey)"
        
        
        otaUpdate.doOTAStartup()
        otaUpdate.delegate = self

        self.title = deviceDetails["serialNumber"] as? String ?? ""
        
        doHideUpdateConfig(hide: true)
        doHideUpdateFirmware(hide: true)
        doHideUpdateEncryptionKey(hide: true)
        
        otaUpdate.doGetTargetVersion()
    }
    
    func doHideUpdateConfig(hide : Bool)
    {
        self.btnUpdateConfig.isHidden = hide
        self.lblRecommendedConfig.isHidden = hide
    }
    
    func doHideUpdateFirmware(hide : Bool)
    {
        self.btnUpdateFirmware.isHidden = hide
        self.lblRecommendedFirmware.isHidden = hide
    }
    
    func doHideUpdateEncryptionKey(hide : Bool)
    {
        if latestEncryptionKey.isEmpty || latestEncryptionKey == "Profile Not Supported by Payrix"
        {
            self.btnUpdateKeyInjection.isHidden = true
            self.lblRecommendedKeyInjection.isHidden = true
        }
        else if currentEncryptionKey != latestEncryptionKey
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
        sharedUtils.showMessage(theController: self, theTitle: "Configuration Version", theMessage: "")
    }
    
    @IBAction func doShowFirmwareInfo(_ sender: Any)
    {
        sharedUtils.showMessage(theController: self, theTitle: "Firmware Version", theMessage: "")
    }
    
    @IBAction func doShowKeyInjectionInfo(_ sender: Any)
    {
        sharedUtils.showMessage(theController: self, theTitle: "Encrytpion Key Version", theMessage: "")
    }
    
    @IBAction func doUpdateConfig(_ sender: Any)
    {
        updatingItem = .config
        self.performSegue(withIdentifier: "SegToProgress", sender: nil)
//        otaUpdate.doOTAConfigUpdate(deviceSettingVersion: latestDeviceSettingVersion, terminalSettingVersion: latestTerminalSettingVersion)
    }
    
    @IBAction func doUpdateFirmware(_ sender: Any)
    {
        updatingItem = .firmware
        self.performSegue(withIdentifier: "SegToProgress", sender: nil)
//        otaUpdate.doOTAFirmwareUpdate(firmwareVersion: latestFirmwareVersion)
    }
    
    @IBAction func doUpdateKeyInjection(_ sender: Any)
    {
        updatingItem = .encryptionKey
        self.performSegue(withIdentifier: "SegToProgress", sender: nil)
//        otaUpdate.doOTAKeyInjection(keyProfile: latestEncryptionKey)
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
            destination.latestEncryptionKey = latestEncryptionKey
            destination.latestFirmwareVersion = latestFirmwareVersion
            destination.latestDeviceSettingVersion = latestDeviceSettingVersion
            destination.latestTerminalSettingVersion  = latestTerminalSettingVersion
            destination.delegateOTACompleted = self
        }
    }
}


extension DemoUpdate : OTAUpdateDelegate
{
    
    func didReceiveRemoteKeyInjectionResult(success: Bool, otaResult: BBDeviceOTAResult, otaMessage: String!)
    {
        print("didReceiveRemoteKeyInjectionResult message : \(otaMessage) \n result: \(otaResult) \n isSuccess : \(success)")
        self.doAnimateIndicator(animate: false)
    }
    
    func didReceiveRemoteFirmwareUpdate(success: Bool, otaResult: BBDeviceOTAResult, otaMessage: String!)
    {
        print("didReceiveRemoteFirmwareUpdate message : \(otaMessage) \n result: \(otaResult) \n isSuccess : \(success)")
        self.doAnimateIndicator(animate: false)
        if success
        {
            sharedUtils.showMessage(theController: self, theTitle: "Firmware Updated successfully.", theMessage: "")
        }
        else
        {
            sharedUtils.showMessage(theController: self, theTitle: "Firmware NOT Updated.", theMessage: "\(otaMessage)")
        }
        
    }
    
    func didReceiveRemoteConfigUpdate(success: Bool, otaResult: BBDeviceOTAResult, otaMessage: String!)
    {
        print("didReceiveRemoteConfigUpdate message : \(otaMessage) \n result: \(otaResult) \n isSuccess : \(success)")
        self.doAnimateIndicator(animate: false)
    }
    
    func didReceiveLocalFirmwareUpdate(success: Bool, otaResult: BBDeviceOTAResult, otaMessage: String!)
    {
        print("didReceiveLocalFirmwareUpdate message : \(otaMessage) \n result: \(otaResult) \n isSuccess : \(success)")
        self.doAnimateIndicator(animate: false)
    }
    
    func didReceiveLocalConfigUpdate(success: Bool, otaResult: BBDeviceOTAResult, otaMessage: String!)
    {
        print("didReceiveLocalFirmwareUpdate message : \(otaMessage) \n result: \(otaResult) \n isSuccess : \(success)")
        self.doAnimateIndicator(animate: false)
    }
    
    func didReceiveTargetVersionResult(success: Bool, otaResult: BBDeviceOTAResult, otaData: [AnyHashable : Any]!)
    {
        print("didReceiveTargetVersionResult otaData : \(otaData) \n result: \(otaResult) \n isSuccess : \(success)")
        
//        device details: ["isCharging": 0, "bootloaderVersion": 5.00.16.22, "batteryPercentage": 73, "isSupportedSoftwarePinPad": 0, "pinKsn": 88888827902615000004, "bID": CHB202927002615, "isUsbConnected": 0, "terminalSettingVersion": BBZZ_Generic_v25, "productID": 4348423230, "vendorID": 42425A5A, "macKsn": 88888827902615600001, "isSupportedTrack3": 0, "uid": 270041001947373439373230, "firmwareVersion": 1.00.03.47, "isSupportedNfc": 1, "serialNumber": CHB202927002615, "hardwareVersion": 1.0.4, "deviceSettingVersion": BBZZ_Generic_v25, "isSupportedTrack2": 1, "isSupportedTrack1": 1, "formatID": 60, "sdkVersion": 3.19.1, "trackKsn": 888888279026154001A5, "emvKsn": 88888827902615200209, "batteryLevel": 3.931]
//
//
//        didReceiveTargetVersionResult otaData : Optional([AnyHashable("terminalSettingVersion"): PIZZ_Generic_v2, AnyHashable("deviceSettingVersion"): PIZZ_Generic_v2, AnyHashable("firmwareVersion"): 1.00.03.47, AnyHashable("keyProfileName"): Payrix MSR])
        
        self.doAnimateIndicator(animate: false)
        
        let otaDataDict = otaData as? [String : AnyObject] ?? [:]
        
        if otaDataDict.isEmpty || otaResult == .failed
        {
            sharedUtils.showMessage(theController: self, theTitle: "Error", theMessage: "")
            return
        }
        
        latestDeviceSettingVersion  = otaDataDict["deviceSettingVersion"] as? String ?? ""//"PIZZ_Generic_v2"
        latestTerminalSettingVersion = otaDataDict["terminalSettingVersion"] as? String ?? ""//"PIZZ_Generic_v2"
        lbllatestVersionConfig.text = "Latest Payrix Version: \(latestDeviceSettingVersion)"
        
        latestFirmwareVersion = otaDataDict["firmwareVersion"] as? String ?? ""//"1.00.03.47"
        lbllatestVersionFirmware.text = "Latest Payrix Version: \(latestFirmwareVersion)"
        
        latestEncryptionKey = otaDataDict["PayrixTargetKeyProfileName"] as? String ?? ""//"Payrix MSR"
        lbllatestVersionKeyInjection.text = "Latest Payrix Version: \(latestEncryptionKey)"
        if (currentTerminalSettingVersion != latestTerminalSettingVersion)
        {
            doHideUpdateConfig(hide: false)
        }
        else
        {
            doHideUpdateConfig(hide: true)
        }
        
        if (currentFirmwareVersion != latestFirmwareVersion)
        {
            doHideUpdateFirmware(hide: false)
        }
        else
        {
            doHideUpdateFirmware(hide: true)
        }
        
        doHideUpdateEncryptionKey(hide: false)
        
    }
    
    
    func didReceiveSetTargetVersionResult(success: Bool, otaResult: BBDeviceOTAResult, otaMessage: String!)
    {
        print("didReceiveSetTargetVersionResult message : \(otaMessage) \n result: \(otaResult) \n isSuccess : \(success)")
        self.doAnimateIndicator(animate: false)
    }
    
    func didReceiveTargetVersionListResult(success: Bool, otaResult: BBDeviceOTAResult, otaList: [Any]!, otaMessage: String!)
    {
        print("didReceiveTargetVersionListResult message : \(otaMessage) \n result: \(otaResult) \n otaList: \(otaList)\n isSuccess : \(success)")
        self.doAnimateIndicator(animate: false)
        
    }
    
    func didReceiveOTAProgress(percentProgress: Float)
    {
        print("didReceiveOTAProgress percentage : \(percentProgress)")
    }
    
    func didReceiveOTAScanResults(success: Bool!, scanMsg: String!, payDevices: [AnyObject]?)
    {
        print("didReceiveOTAScanResults scanMsg : \(scanMsg) \n payDevices: \(payDevices) \n isSuccess : \(success)")
        self.doAnimateIndicator(animate: false)
    }
    
    func didReceiveOTAConnectResults(success: Bool!, theDevice: String!)
    {
        print("didReceiveOTAConnectResults thedevice : \(theDevice) \n isSuccess : \(success)")
        self.doAnimateIndicator(animate: false)
    }
    
    func didReceiveOTADisconnectResults(success: Bool!)
    {
        print("didReceiveOTADisconnectResults : \(success)")
        self.doAnimateIndicator(animate: false)
    }
    
    
    func isDeviceReadyForUpdate()
    {
        
    }
}

extension DemoUpdate : OTACompleteDelegate
{
    func otaCompleted(message : String, info : String)
    {
        sharedUtils.showMessage(theController: self, theTitle: message, theMessage: info)
        activityIndicator.startAnimating()
        otaUpdate.delegate = self
        otaUpdate.doGetTargetVersion()
    }
}
