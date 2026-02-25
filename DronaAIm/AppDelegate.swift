//
//  AppDelegate.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 24/05/24.
//

import UIKit
import IQKeyboardManagerSwift
import QuickLook
import GoogleMaps
import AWSCognitoAuthPlugin
import Amplify
import UserNotifications
import Firebase
import FirebaseCrashlytics

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        configAmplify()
        configFirebase()
        IQKeyboardManager.shared.enable = true
        setupApplicationUIAppearance()
        GMSServices.provideAPIKey(LSConstants.APIKeys.googleMapsAPIKey)
        LSPushNotificationProcess.shared.config()
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)

        // Request notification permission
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL else {
            return false
        }
        LSLogger.info("Universal Links: \(url)")
        return true
    }
    
    private func setRootviewController() {
        // Create a new UIWindow with the screen bounds
        window = UIWindow(frame: UIScreen.main.bounds)

        let decisionVC = LSDecisionViewController()
        let navigationController = UINavigationController(rootViewController: decisionVC)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    private func configAmplify() {
            do {
                try Amplify.add(plugin: AWSCognitoAuthPlugin())
                try Amplify.configure()
                LSLogger.info("Amplify configured successfully")
            } catch {
                LSLogger.error("Failed to configure Amplify: \(error)")
            }
    }
    
    private func configFirebase() {
        // The build script copies the environment-specific GoogleService-Info file
        // to GoogleService-Info.plist in the app bundle, so Firebase can auto-detect it
        FirebaseApp.configure()
        LSLogger.info("Firebase configured successfully")
    }
    
    /// Test method to force a crash (for testing Crashlytics only)
    /// ⚠️ WARNING: Do not call this in production builds!
    /// To test: Uncomment the fatalError line and call this method
    static func testCrashlytics() {
        // Force a crash (for testing only)
        // fatalError("🧪 Test Crash - Crashlytics is working!")
        LSLogger.warning("testCrashlytics() called but fatalError is commented out for production safety")
    }
    
    /// Test method to log a non-fatal error to Crashlytics
    /// This won't crash the app, just logs an error
    static func testNonFatalError() {
        let error = NSError(domain: "com.dronaaim.test", code: 999, userInfo: [
            NSLocalizedDescriptionKey: "Test non-fatal error for Crashlytics"
        ])
        Crashlytics.crashlytics().record(error: error)
        LSLogger.info("Test non-fatal error logged to Crashlytics")
    }


    private func setupApplicationUIAppearance() {
        // Set navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.appTheme
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.shadowColor = .clear

        let backButtonAppearance = UIBarButtonItemAppearance(style: .plain)
        backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]

        appearance.backButtonAppearance = backButtonAppearance

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = .white
        
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)

    }
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // Called when APNs successfully registers the device and returns a device token
       func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
           let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
           let token = tokenParts.joined()
           LSLogger.info("Device Token registered: \(token)")
           // Send token to the server (AWS SNS)
           if token != UserDefaults.standard.string(forKey: "lastDeviceToken") {
               // Send to backend
               if let userDetails = UserDefaults.standard.userDetails {
                   let endpoint = LSAPIEndpoints.registerDeviceToken(for: userDetails.userId)
                   let requestbody = LSRequstTokenRegister(token: token)
                   Task { do {
                       let response: LSSuccess = try await LSNetworkManager.shared.post(endpoint, body: requestbody)
                       UserDefaults.standard.set(token, forKey: "lastDeviceToken")
                       LSLogger.info("Device token registration successful")
                   } catch {
                       LSLogger.error("Failed to register device token: \(error.localizedDescription)")
                   }
                }
               }
           }
       }

       // Called when APNs fails to register the device
       func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
           LSLogger.error("Failed to register for remote notifications: \(error)")
       }
    
    // This method is called when a push notification is received while the app is running
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        LSLogger.info("Push notification received: \(userInfo)")
        LSLogger.debug("Notification values: \(userInfo.values)")
    }


}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // This method will be called when the app is in the foreground and a notification is received
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Present the notification as a banner, sound, and badge even when the app is in the foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    // Handle notification when the app is opened by tapping on it
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        // Access the notification content
        let userInfo = response.notification.request.content.userInfo
        
        // Identify custom data (e.g., notificationType)
        LSLogger.debug("Notification keys: \(userInfo.keys)")
        LSLogger.debug("Notification values: \(userInfo.values)")

        if let notificationType = userInfo["notificationType"] as? String {
            switch notificationType {
            case "message":
                // Handle user tapping on a "message" notification
                LSLogger.info("User tapped on a message notification")
                // Navigate to the message screen, for example
            case "event":
                // Handle user tapping on an "event" notification
                LSLogger.info("User tapped on an event notification")
                // Navigate to the event screen, for example
            default:
                break
            }
        }
        
        // Call completion handler
        completionHandler()
    }

}


struct LSRequstTokenRegister: Encodable {
    let token: String
    let deviceType: String = "iOS"
}
struct LSRequstEmpty: Encodable {
    let empty: String
}

