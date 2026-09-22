import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var nativeBridge: NativeBridge?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    do {
      let nativeBridge = NativeBridge(storage: try PinStorage.makeDefault())
      nativeBridge.register(binaryMessenger: engineBridge.applicationRegistrar.messenger())
      self.nativeBridge = nativeBridge
    } catch {
      fatalError("iOSのPin保存先を初期化できませんでした: \(error.localizedDescription)")
    }
  }
}
