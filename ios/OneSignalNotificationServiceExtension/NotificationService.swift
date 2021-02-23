import UserNotifications

import OneSignal

class NotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var receivedRequest: UNNotificationRequest!
    var bestAttemptContent: UNMutableNotificationContent?
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.receivedRequest = request;
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            OneSignal.didReceiveNotificationExtensionRequest(self.receivedRequest, with: self.bestAttemptContent)
            contentHandler(bestAttemptContent)
        }
        // this is way to get additional payload
        let dict = request.content.userInfo
        let custom = dict["custom"] as? String
        let aps = dict["aps"] as? String

        print("Running NotificationServiceExtension: custom = \(custom ?? "")")
        print("Running NotificationServiceExtension: aps = \(aps ?? "")")
        // if additional payload is got successfully then save it toNSUserDefaults
//        UserDefaults.standard.set(custom, forKey: "flutter.add")
//        UserDefaults.standard.set("1", forKey: "flutter.os")
//        // now launcg the app somehow
//        runAfterDelay(2.0) {  // 2 second delay, not sure if needed but doesn't seem to hurt - runAfterDelay function is below
//            NotificationCenter.default.post(name: Notification.Name(rawValue: NSLocalizedString("ticker_notification_name", comment: "")), object: request)
//        }
        
        // wrtie code here to open app
        
        
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            OneSignal.serviceExtensionTimeWillExpireRequest(self.receivedRequest, with: self.bestAttemptContent)
            contentHandler(bestAttemptContent)
            print("Yes it is called")
        }
    }
//    func runAfterDelay(_ delay: Double, closure:@escaping ()->()) {
//        let when = DispatchTime.now() + delay
//        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
//    }
}
