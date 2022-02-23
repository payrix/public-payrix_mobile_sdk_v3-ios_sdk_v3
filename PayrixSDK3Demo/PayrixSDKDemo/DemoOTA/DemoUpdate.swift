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
    
    let payrixOTA = PayrixOTA.sharedInstance
    let payrixSDK = PayrixSDK.sharedInstance
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
        
        payrixOTA.doOTAStartup()

        setUpVersionLabels()
        
        doHideUpdateConfig()
        doHideUpdateFirmware()
        doHideUpdateEncryptionKey()
        
        doGetOTAVersions()
    }
    
    func setUpVersionLabels()
    {
        currentFirmwareVersion = deviceDetails["firmwareVersion"] as? String ?? ""
        lblCurrentVersionFirmware.text = "Current Version: \(currentFirmwareVersion)"
        
        currentDeviceSettingVersion = deviceDetails["deviceSettingVersion"] as? String ?? ""
        currentTerminalSettingVersion = deviceDetails["terminalSettingVersion"] as? String ?? ""
        lblCurrentVersionConfig.text = "Current Version: \(currentTerminalSettingVersion)"
        
        
        currentEncryptionKey = deviceDetails["PayrixCurrentKeyProfileName"] as? String ?? ""
        lblCurrentVersionKeyInjection.text = "Current Version: \(currentEncryptionKey)"
        
        self.title = deviceDetails["serialNumber"] as? String ?? ""
    }
    
    func doGetDeviceDetails()
    {
        payrixSDK.delegate = self
        payrixSDK.doGetDeviceInfo()
    }
    
    func doGetOTAVersions()
    {
        payrixOTA.delegate = self
        payrixOTA.doGetTargetVersion()
    }
    
    func doHideUpdateConfig()
    {
        if (currentTerminalSettingVersion == latestTerminalSettingVersion) || latestTerminalSettingVersion.isEmpty
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
        if (currentFirmwareVersion == latestFirmwareVersion) || latestFirmwareVersion.isEmpty
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
        payrixOTA.doOTADisconnectAnyDevice()
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
        self.doAnimateIndicator(animate: false)
    }
    
    func didReceiveRemoteFirmwareUpdate(success: Bool, otaResult: BBDeviceOTAResult, otaMessage: String!)
    {
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
        self.doAnimateIndicator(animate: false)
    }
    
    func didReceiveLocalFirmwareUpdate(success: Bool, otaResult: BBDeviceOTAResult, otaMessage: String!)
    {
        self.doAnimateIndicator(animate: false)
    }
    
    func didReceiveLocalConfigUpdate(success: Bool, otaResult: BBDeviceOTAResult, otaMessage: String!)
    {
        self.doAnimateIndicator(animate: false)
    }
    
    func didReceiveTargetVersionResult(success: Bool, otaResult: BBDeviceOTAResult, otaData: [AnyHashable : Any]!)
    {
        self.doAnimateIndicator(animate: false)
        let otaDataDict = otaData as? [String : AnyObject] ?? [:]
        
        if otaDataDict.isEmpty || otaResult == .failed
        {
            sharedUtils.showMessage(theController: self, theTitle: "Error", theMessage: "")
            return
        }
        
        latestDeviceSettingVersion  = otaDataDict["deviceSettingVersion"] as? String ?? ""
        latestTerminalSettingVersion = otaDataDict["terminalSettingVersion"] as? String ?? ""
        lbllatestVersionConfig.text = "Latest Payrix Version: \(latestDeviceSettingVersion)"
        
        latestFirmwareVersion = otaDataDict["firmwareVersion"] as? String ?? ""
        lbllatestVersionFirmware.text = "Latest Payrix Version: \(latestFirmwareVersion)"
        
        latestEncryptionKey = otaDataDict["PayrixTargetKeyProfileName"] as? String ?? ""
        lbllatestVersionKeyInjection.text = "Latest Payrix Version: \(latestEncryptionKey)"
        
        doHideUpdateConfig()
        doHideUpdateFirmware()
        doHideUpdateEncryptionKey()
        
    }
    
    
    func didReceiveSetTargetVersionResult(success: Bool, otaResult: BBDeviceOTAResult, otaMessage: String!)
    {
        self.doAnimateIndicator(animate: false)
    }
    
    func didReceiveTargetVersionListResult(success: Bool, otaResult: BBDeviceOTAResult, otaList: [Any]!, otaMessage: String!)
    {
        self.doAnimateIndicator(animate: false)
        
    }
    
    func didReceiveOTAProgress(percentProgress: Float)
    {
    }
    
    func didReceiveOTAScanResults(success: Bool!, scanMsg: String!, payDevices: [AnyObject]?)
    {
        self.doAnimateIndicator(animate: false)
    }
    
    func didReceiveOTAConnectResults(success: Bool!, theDevice: String!)
    {
        self.doAnimateIndicator(animate: false)
    }
    
    func didReceiveOTADisconnectResults(success: Bool!)
    {
        self.doAnimateIndicator(animate: false)
        self.navigationController?.popViewController(animated: true)
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
        doGetOTAVersions()
    }
}
