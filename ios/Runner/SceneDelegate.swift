import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions,
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)
    connectionOptions.userActivities.forEach { ArcadeLinkURLBridge.shared.handle($0) }
  }

  override func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
    ArcadeLinkURLBridge.shared.handle(userActivity)
    super.scene(scene, continue: userActivity)
  }
}
