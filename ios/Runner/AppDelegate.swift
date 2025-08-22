import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    let backupChannel = FlutterMethodChannel(name: "org.app.caravella/backup",
                                            binaryMessenger: controller.binaryMessenger)
    
    backupChannel.setMethodCallHandler({
        (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
        switch call.method {
        case "setBackupExcluded":
            guard let args = call.arguments as? [String: Any],
                  let excluded = args["excluded"] as? Bool else {
                result(FlutterError(code: "INVALID_ARGUMENT", 
                                   message: "Expected excluded boolean argument", 
                                   details: nil))
                return
            }
            self.setBackupExcluded(excluded: excluded, result: result)
        case "isBackupExcluded":
            self.isBackupExcluded(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    })
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func setBackupExcluded(excluded: Bool, result: @escaping FlutterResult) {
      do {
          let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
          let documentsURL = URL(fileURLWithPath: documentsPath)
          
          var resourceValues = URLResourceValues()
          resourceValues.isExcludedFromBackup = excluded
          try documentsURL.setResourceValues(resourceValues)
          
          result(true)
      } catch {
          result(FlutterError(code: "BACKUP_ERROR", 
                             message: "Failed to set backup exclusion: \(error.localizedDescription)", 
                             details: nil))
      }
  }
  
  private func isBackupExcluded(result: @escaping FlutterResult) {
      do {
          let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
          let documentsURL = URL(fileURLWithPath: documentsPath)
          
          let resourceValues = try documentsURL.resourceValues(forKeys: [.isExcludedFromBackupKey])
          let isExcluded = resourceValues.isExcludedFromBackup ?? false
          
          result(!isExcluded) // Return true if backup is enabled (not excluded)
      } catch {
          result(FlutterError(code: "BACKUP_ERROR", 
                             message: "Failed to check backup exclusion: \(error.localizedDescription)", 
                             details: nil))
      }
  }
}
