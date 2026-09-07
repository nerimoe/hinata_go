import SwiftUI

@main
struct ArcadeLinkClipApp: App {
  @StateObject private var model = MachineLoginViewModel()

  var body: some Scene {
    WindowGroup {
      MachineLoginView()
        .environmentObject(model)
        .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { activity in
          guard let url = activity.webpageURL else { return }
          Task { await model.handleInvocation(url) }
        }
        .onOpenURL { url in
          Task { await model.handleInvocation(url) }
        }
    }
  }
}
