# Payrix iOS SDK Version 3.0
## Release Note Summary:
- Version 3.0.23 (EMV Certified)
  * Fixed crash when searching for non-Payrix devices.
- Version 3.0.22 (EMV Certified)
  * Updated PrivacyInfo.xcprivacy with NSPrivacyTracking to true
- Version 3.0.21 (EMV Certified)
  * Successfully updated the SDK to use to utilize TxnSessionKey for transaction operations. This enables transactions, refunds, reverse authentication, and transaction history retrieval using both TxnSessionKey and LoginSessionKey.
  * Updated PrivacyInfo.xcprivacy file to comply with Apple's new privacy regulations.
  * Supplementary Documentation [here](sdkdocumentation/Payrix_iOS_SDK_Dev_TxnSessopm.pdf)
- Version 3.0.20 (EMV Certified)
  * Resolved the issue of iOS Mobile SDK Cannot Cancel Transaction After Decline
- Version 3.0.19 (EMV Certified)
  * Successfully updated the SDK to include the added error message in the infoMsg parameter of the didReceivePayResults method.
- Version 3.0.18 (EMV Certified)
  * Successfully addressed the error in getTargetVersion function within the OTA SDK, predominantly observed for CHB2F devices.
  * Introduced a new method, setDebugLog(enable:), facilitating enhanced logging within the OTA process.
  * Exclusive compatibility with Xcode14 and higher versions, aligned with Apple's Bitcode Support deactivation announcement.
  * To accommodate older versions, a BelowXcode14 folder is available, housing both BitcodeEnabled and Disabled SDKs. However, the folder lacks the fix for the getTargetVersion method related to CHB2F Devices.
- Version 3.0.17 (EMV Certified)
  * Resolved the issue for showing error for Timeout in case of Transaction.

- Version 3.0.16 (EMV Certified)
  * Resolved the issue for crash occurring when Payrix SDK finds the devices that has same UUID as BBPos but has no name on it.

- Version 3.0.15 (EMV Certified)
  * Resolved the issue for ReverseAuth occurring when Payrix API does not handle Tag 8A length correctly.
  * Resolved decoding when a field can be presented as both Integer or String.

- Version 3.0.14 (EMV Certified)
  * Skipped these versions - 3.0.11, 3.0.12, 3.0.13. to match the Android SDK version update.
  * Fixed the delegate callback for connecting the readers - earlier no callback was returned from SDK if the given device is not found on scan result but now the desired error is being passed from SDK
  * In order to connect relaibly from SDK, added multiple methods that supports to scan the reader effectively. Because of this the maximum waiting time for getting device data back is 40 seconds and minimum time is less than a second. To do this - Passed the deviceId too in BBPOS-SDK so that BBPOS-SDK search for given device first, if the scan results does not get back in 20 seconds then PayrixSDK will search for BLE devices using standard BLE protocol, that takes another 20 seconds, so in worst case scebario it takes 40 seconds in total for returing the device.
     
- Version 3.0.10 - 3.0.13 (EMV Certified)
  * Fixed the Encryption Key issue for Chipper 3x BT
  * Updated message for "Device Error: 28 - Peer removed pairing information"
  * Fixed the issue with saved card type in case of failure

- Version 3.0.9 (EMV Certified)
  * Fixed the callback for "Device Error: 28 - Peer removed pairing information" error. didReceiveBTConnectResults method is called with message for the error.
  
- Version 3.0.8 (EMV Certified)
  * Fixed issue with Refund
  * Updated message fromm SDK in case of No merchants can be fetched for the logged in user.
  
- Version 3.0.7 (EMV Certified)
  * Return the name printed on card as ccName on PayResponse:
    This only works if BBPos SDK returns the name printed on card and the payDeviceMode is set to PaySharedAttributes.PayDeviceMode.cardDeviceMode_Swipe

- Version 3.0.6 (EMV Certified)
  * Added orderNumber funtionality:
    New SDK code will accept order as parameter in PayRequest.
  * Fix the crash on Magstripe for faulty cards.


- Version 3.0.5 (EMV Certified)
  * Added new Single Merchant Retieval funtionality:
    New SDK Method: doGetSingleMerchant(merchantID, sessionKey) | New Callback:  didReceiveSingleMerchantRetrievalResults(...)
  * Resolved issue with PayDevice Singleton

- Version 3.0.4 (EMV Certified)
  * Added support for Cancel Transaction in SDK. Note: Cancel only works when the device is waiting for the card to be presented as a Tap, Chip Insert, or Swipe.  The SDK ignores all other Cancel requests once the card is presented.
  * OTA (Over the Air) Defect Update to Encryption Key Profile Management: In case of OTA Target key profile is set to an invalid value on bbPOS' TMS, the SDK will set the target key profile to Sandbox key profile.
  * Added new object PaymentDevice to provide a non-singleton device object, until PayDevice can be depricated or revised.

- Version 3.0.3 (EMV Certified) 
  * Added multi-Currency Support.  Note: Not Announced as GA on Payrix Platform.  Currencies: USD, CAD, GBP, AUD, EUR
  
- Version 3.0.2 (EMV Certified)
  * This patch is to resolve an issue with Manual Card Entry where the some txns data was not being returned correctly, specifically "creation date".
- Version 3.0.1 (EMV Certified)
  * This patch is to provide a work-around of an Apple Swift bug that does not allow the SDK name and a Class name to be the same.  To resolve the issue Payrix has changed the class name from PayrixSDK to PayrixSDKMaster.  The only change to the customer app is whenever the SDK is instantiated.  let payrixSDK = PayrixSDKMaster.sharedInstance.
- Version 3.0.0 (EMV Certified)
  * This release of the Payrix iOS SDK is completely restructured under a single framework that give the user full access to all of the services provided by previous SDK versions.

## SDK Process Map of SDK Functions (Methods and Callbacks)

![](SDKDocumentation/PayrixSDK_Process_Map_Pg1.png)

![](SDKDocumentation/PayrixSDK_Process_Map_Pg2.png)

![](SDKDocumentation/PayrixSDK_Process_Map_Pg3.png)

![](SDKDocumentation/PayrixSDK_Process_Map_Pg4.png)

![](SDKDocumentation/PayrixSDK_Process_Map_Pg5.png)
