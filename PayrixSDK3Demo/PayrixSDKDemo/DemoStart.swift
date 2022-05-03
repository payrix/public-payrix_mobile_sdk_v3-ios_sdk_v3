//
//  DemoStart.swift
//  PayrixSDKDemo
//
//  Created by Steve Sykes on 7/20/20.
//  Copyright © 2020 Payrix. All rights reserved.
//

import UIKit
import PayrixSDK

class DemoStart: UIViewController, PayrixSDKDelegate
{
  @IBOutlet weak var btnAuthenticate: UIButton!
  @IBOutlet weak var btnScanReader: UIButton!
  @IBOutlet weak var btnPaymentTxn: UIButton!
  @IBOutlet weak var btnRefund: UIButton!
  
  @IBOutlet weak var lblProcessingLog: UITextView!
  @IBOutlet weak var lblVersionInfo: UILabel!
  @IBOutlet weak var sgmOpsEnv: UISegmentedControl!
  
  let sharedUtils = SharedUtilities.init()
  let payrixSDK = PayrixSDKMaster.sharedInstance
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }
  
  override func viewWillAppear(_ animated: Bool)
  {
    super.viewWillAppear(animated)
    let _ = payrixSDK.doDebugEnable(enableDebug: false)
    if !sharedUtils.checkNetworkConnection()
    {
      sharedUtils.showMessage(theController: self, theTitle: "Payrix SDK Demo App", theMessage: "The Network Connection is Not Available; Resolve and Retry")
      btnPaymentTxn.isHidden = true
      btnScanReader.isHidden = true
      btnAuthenticate.isHidden = true
    }
    else
    {
      btnPaymentTxn.isHidden = false
      btnScanReader.isHidden = false
      btnAuthenticate.isHidden = false
    }
    
    let infoDictionary = Bundle.main.infoDictionary
    let appVersion: String = infoDictionary!["CFBundleShortVersionString"] as! String
    let appBuildNumber: String = infoDictionary!["CFBundleVersion"] as! String
    let arcVersion: String = "Version: " + appVersion + " (Build: " + appBuildNumber + ")"
    lblVersionInfo.text = arcVersion
  
    let useEnvSel = sharedUtils.getEnvSelection() ?? "api.payrix.com"
    let useSandBox = sharedUtils.getSandBoxOn() ?? true
    
    if useSandBox
    {
      sgmOpsEnv.selectedSegmentIndex = 0
    }
    else
    {
      sgmOpsEnv.selectedSegmentIndex = 1
    }
  }
  
  
  @IBAction func goEnvChanged(_ sender: Any)
  {
    let useSegment = sender as! UISegmentedControl
    
    let selection = useSegment.selectedSegmentIndex
    
    switch selection
    {
    case 0:
      sharedUtils.setSandBoxOn(selSandBox: true)
      sharedUtils.setEnvSelection(selEnv: "api.payrix.com")
      // payrixSDK.doDebugEnable(enableDebug: true)
      break
//    case 1:
//      sharedUtils.setSandBoxOn(selSandBox: false)
//      sharedUtils.setEnvSelection(selEnv: "emv-test.payrix.com")
//      // payrixSDK.doDebugEnable(enableDebug: true)
//      break
    case 1:
      sharedUtils.setSandBoxOn(selSandBox: false)
      sharedUtils.setEnvSelection(selEnv: "api.payrix.com")
      // payrixSDK.doDebugEnable(enableDebug: false)
      break
    default:
      sharedUtils.setSandBoxOn(selSandBox: true)
      sharedUtils.setEnvSelection(selEnv: "api.payrix.com")
      // payrixSDK.doDebugEnable(enableDebug: true)
      break
    }
  }
  
  /**
  **goAuthenticate**
  The method branches over to the Authenticate UI for processing
  - Parameters:
    - sender: The button view object
  */
  @IBAction func goAuthenticate(_ sender: Any)
  {
    performSegue(withIdentifier: "SegToAuth", sender: self)
  }
  
  /**
  **goScanReader**
  The method branches over to the Bluetooth Scan and Set UI for processing
  - Parameters:
    - sender: The button view object
  */
  @IBAction func goScanReader(_ sender: Any)
  {
    performSegue(withIdentifier: "SegToScan", sender: self)
  }
  
  /**
  **goPaymentTxn**
  The method branches over to the Payment Transaction UI for processing
  - Parameters:
    - sender: The button view object
  */
  @IBAction func goPaymentTxn(_ sender: Any)
  {
    performSegue(withIdentifier: "SegToTxn", sender: self)
  }
  
  @IBAction func goRefundTxn(_ sender: Any)
  {
     // performSegue(withIdentifier: "SegToRefundList", sender: self)
    let theConsoleLog = payrixSDK.doDebugEnable(enableDebug: false)
    payrixSDK.doWriteConsoleFile(fileName: "PayrixSDK-Console", fileData: theConsoleLog ?? "No Console Data")
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?)
  {
    guard let segID = segue.identifier else { return }
    if segID == "SegToAuth"
    {
      // Prep for Authentication Processing
      let _ = segue.destination as! DemoAuthentication
    }
    else if segID == "SegToScan"
    {
      // Prep for Bluetooth Scanning Processing
      let _ = segue.destination as! DemoScanBT
    }
    else if segID == "SegToTxn"
    {
        // Prep for Transaction Processing
        let _ = segue.destination as! DemoTransaction
    }
  }
}
