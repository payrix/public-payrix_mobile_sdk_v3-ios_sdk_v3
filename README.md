# Payrix iOS SDK Version 3.0.6
## Release Note Summary:
- Version 3.0.6 (EMV Certified)
  * Added orderNumber funtionality:
    New SDK function will accept order as element in PayRequest object.
  * Fix the crash on Swipe for faulty cards.
  
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
