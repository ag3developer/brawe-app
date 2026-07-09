import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)
    
    // Configurar Brawe Audio MethodChannel após FlutterViewController estar pronto
    if let flutterViewController = self.window?.rootViewController as? FlutterViewController {
      BraweAudioSetup.setupAudioChannel(binaryMessenger: flutterViewController.binaryMessenger)
    }
  }
}
