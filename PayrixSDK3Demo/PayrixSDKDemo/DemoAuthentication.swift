//
//  DemoAuthentication.swift
//  PayrixSDKDemo
//
//  Created by Steve Sykes on 7/22/20.
//  Copyright © 2020 Payrix. All rights reserved.
//

import UIKit
import PayrixSDK

class DemoAuthentication: UIViewController, UITextFieldDelegate, PayrixSDKDelegate
{
	//hardcode stuff
	let username = ""
	let password = ""
	let merchantId = ""
	let APIKey = ""
	
  @IBOutlet weak var txtUserID: UITextField!
  @IBOutlet weak var txtUserPwd: UITextField!
  @IBOutlet weak var lblResults: UITextView!
  
  @IBOutlet weak var btnBack: UIButton!
  @IBOutlet weak var btnAuthenticate: UIButton!
  
  let sharedUtils = SharedUtilities.init()
    var payMerchants : [PayMerchant] = []
  
  /**
  * Step 1: Instantiate the PayCoreMaster instance.  This class handles authentication.
  */
  let payrixSDK = PayrixSDKMaster.sharedInstance
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool)
  {
    super.viewWillAppear(animated)
    
    /*
    * Step 2:
    * a. Set the host URL
    * b. Set Demo - Sandbox mode
    */
    
    let isSandBox =  sharedUtils.getSandBoxOn()!
    let theEnv =  sharedUtils.getEnvSelection()!
    
    payrixSDK.doSetPayrixPlatform(platform: theEnv, demoSandbox: isSandBox, deviceManfg: nil)
        
    sharedUtils.setDemoMode(modeKey: isSandBox)
    if sharedUtils.getIsMerchantSelected()
    {
       let logMsg = "Authentication Successful: \n" + "- Merchant ID: " + sharedUtils.getMerchantID()! + "\n- Merchant DBA: " + sharedUtils.getMerchantDBA()!
       updateLog(newMessage: logMsg)
       sharedUtils.setIsMerchantSelected(selected: false)
    }
    else
    {
       lblResults.text = ""

       txtUserID.text = username//""
       txtUserPwd.text = password//""
    }
      
    txtUserID.delegate = self
    txtUserPwd.delegate = self
  }
  
  @IBAction func goBack(_ sender: Any)
  {
    self.dismiss(animated: true, completion: nil)
  }
  

  /**
  **goAuthenticate**
  (Step 3)
  * This method listens for the Authenticate button to be tapped
  * The method verifies that valid input was entered and the proceeds
  * to authenticate with the gateway platform (Payrix).
  * The response from the gateway is via the Callback: didReceiveLoginResponse
  
  - Parameters:
    - sender: This represents the button object
  */
  @IBAction func goAuthenticate(_ sender: Any)
  {
    if doCheckValidInput()
    {
      lblResults.text = "Starting Authentication..."
      payrixSDK.delegate = self
      payrixSDK.doValidateCredentials(userID: txtUserID.text ?? "", password: txtUserPwd.text ?? "")
    }
  }
	
	@IBAction func goGetTxnSessionKey(_ sender: Any)
	{
		
		let configuration = TxnSessionConfiguration()
		configuration.duration = 3000// The number of times this key can be used for requests. Default is 8.
		configuration.maxTimesApproved = 200// The maximum number of approved transactions that can be associated with this key. Default is 4.
		configuration.maxTimesUse = 100 // The time in minutes the key remains valid; it's automatically voided when expired. Default is 10.
		
		payrixSDK.delegate = self
		payrixSDK.doGetTxnSessionKey(
			apiKey: APIKey,
			merchantID: merchantId,
		configuration: configuration)
	}
	
	@IBAction func goGetTxnSessionDeatil(_ sender: Any)
	{
		if let sessionId = sharedUtils.getTxnSessionID()
		{
			payrixSDK.delegate = self
			payrixSDK.doGetTxnSession(apiKey: APIKey, sessionId: sessionId)
		}
		else
		{
			print("No SessionId")
		}
	}
	
	@IBAction func goDeleteTxnSession(_ sender: Any)
	{
		if let sessionId = sharedUtils.getTxnSessionID()
		{
			payrixSDK.delegate = self
			payrixSDK.doDeleteTxnSession(apiKey: APIKey, sessionId: sessionId)
		}
		else
		{
			print("No SessionId")
		}
	}
	
	
	
	public func didReceiveTxnKeyResult(success: Bool!, txnSession: PayCoreTxnSession?, theMessage: String!)
	{
		if success,
			 let session = txnSession,
			 let txnSessionKey = session.key,
			 let txnSessionID = session.sessionId
		{
			//set all values to nil what are being set while using Login with username and password
			sharedUtils.setSessionKey(sessionKey: "")
			sharedUtils.setMerchantID(merchantKey: "")
			sharedUtils.setMerchantDBA(merchantDBA: "")
			sharedUtils.setTxnSessionID(key: "")
			sharedUtils.setTxnSessionKey(key: "")
			//setting new values to shared utils what can use for TxnSessionKey
			self.sharedUtils.setTxnSessionKey(key: txnSessionKey)
			self.sharedUtils.setTxnSessionID(key: txnSessionID)
			//setting up the merchant
			self.sharedUtils.setMerchantID(merchantKey: merchantId)
			let logMsg = "Fetched Transaction Session Key: \n" + "- TxnSessonKey: " + txnSessionKey + "\n- SessionId: " + txnSessionID
			self.updateLog(newMessage: logMsg)
		}
		else
		{
			let logMsg = "Error on Fetching Transaction Session Key: \n" + (theMessage ?? "")
			self.updateLog(newMessage: logMsg)
		}
	}
	
  public func didReceiveLoginResults(loginSuccess: Bool!, theSessionKey: String?, theMerchants: [AnyObject]?, theMessage: String!)
	{
		if loginSuccess
		{
			sharedUtils.setSessionKey(sessionKey: theSessionKey!)
			sharedUtils.setTxnSessionID(key: "")
			sharedUtils.setTxnSessionKey(key: "")
			var payMerchant = PayMerchant.sharedInstance
			if let useMerchants = theMerchants as? [PayMerchant]
			{
				if useMerchants.count > 1
				{
					self.payMerchants = useMerchants
					self.performSegue(withIdentifier: "SegToMerchants", sender: nil)
				}
				else
				{
					payMerchant = useMerchants[0]
					// Save Merchant Info
					sharedUtils.setMerchantID(merchantKey: payMerchant.merchantID!)
					sharedUtils.setMerchantDBA(merchantDBA: payMerchant.merchantDBA!)
					let logMsg = "Authentication Successful: \n" + "- Merchant ID: " + payMerchant.merchantID! + "\n- Merchant DBA: " + payMerchant.merchantDBA!
					updateLog(newMessage: logMsg)
				}
			}
			hideKeyboard()
		}
		else
		{
			let useError = "Error: " + theMessage;
			sharedUtils.showMessage(theController: self, theTitle: "Authentication", theMessage: useError)
			
			let logMsg = "Authentication Error: \n" + theMessage
			updateLog(newMessage: logMsg)
		}
	}
  
	override func prepare(for segue: UIStoryboardSegue, sender: Any?){
		guard let segID = segue.identifier else { return }
		if segID == "SegToMerchants"
		{
			// Prep for Authentication Processing
			let merchantLists : DemoMerchantsList = segue.destination as! DemoMerchantsList
			merchantLists.payMerchants = payMerchants
		}	
	}
  
  /**
  **updateLog**
  * This method updates the UI Log of authentication events
  - Parameters:
    - newMessage: The String message to be displayed
  */
  private func updateLog(newMessage: String)
  {
    var currentLog = lblResults.text
    currentLog = currentLog! + "\n" + newMessage
    lblResults.text = currentLog
  }
  
  private func doCheckValidInput() -> Bool
  {
    if (txtUserID.text == nil || txtUserID.text == "") || (txtUserPwd.text == nil || txtUserPwd.text == "")
    {
      return false
    }
    else
    {
      return true
    }
  }
  
  
  /**
  **textFieldShouldReturn**
  * This method handles jumping between UI fields when tapping the Next key.
  - Parameters:
    - textField: The current textfield selected
  - Returns:
    - Bool returns False to ignore normal key processing
  */
  func textFieldShouldReturn(_ textField: UITextField) -> Bool
  {
     // Try to find next responder
     if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField
     {
        nextField.becomeFirstResponder()
     }
     else
     {
        // Not found, so remove keyboard.
        textField.resignFirstResponder()
     }
     // Do not add a line break
    
    if textField.tag == 102
    {
      goAuthenticate(self)
    }
     return false
  }
  
  
  func hideKeyboard()
  {
    view.endEditing(true)
  }
}
