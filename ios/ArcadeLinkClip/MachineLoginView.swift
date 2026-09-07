import SwiftUI

struct MachineLoginView: View {
  @EnvironmentObject private var model: MachineLoginViewModel
  @Environment(\.openURL) private var openURL

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 20) {
        header

        switch model.state {
        case .idle, .loadingMachine:
          ProgressView("正在连接机台…")
            .frame(maxWidth: .infinity, alignment: .center)
        case .unauthenticated:
          authenticationView
        case .ready:
          cardsView
        case .locating, .sending:
          ProgressView(model.state == .locating ? "正在确认位置…" : "正在登录机台…")
            .frame(maxWidth: .infinity, alignment: .center)
        case .success:
          successView
        case .failed:
          failedView
        }
      }
      .padding(24)
    }
    .background(Color(.systemGroupedBackground))
    .task {
      if model.state == .idle {
        // The App Clip invocation is delivered through onContinueUserActivity.
      }
    }
  }

  private var header: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("HINATA Go")
        .font(.caption.weight(.semibold))
        .foregroundStyle(.secondary)
        .textCase(.uppercase)
      if let machine = model.machine {
        Text(machine.shop.name)
          .font(.title2.weight(.semibold))
        Text(machine.name)
          .font(.title3)
          .foregroundStyle(.secondary)
      } else {
        Text("ArcadeLink")
          .font(.title2.weight(.semibold))
      }
    }
  }

  private var authenticationView: some View {
    VStack(alignment: .leading, spacing: 14) {
      Text("登录账号后即可选择 Aime 卡片。")
        .foregroundStyle(.secondary)
      Button {
        Task { await model.authenticateWithPasskey() }
      } label: {
        Label("使用 Passkey", systemImage: "person.badge.key.fill")
          .frame(maxWidth: .infinity)
      }
      .buttonStyle(.borderedProminent)

      Button {
        Task { await model.authenticateWithMunet() }
      } label: {
        Label("使用 MuNET 登录", systemImage: "person.crop.circle.badge.checkmark")
          .frame(maxWidth: .infinity)
      }
      .buttonStyle(.bordered)

      if let url = model.webFallbackURL {
        Button {
          openURL(url)
        } label: {
          Label("使用网页版登录", systemImage: "safari")
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
      }
    }
  }

  private var cardsView: some View {
    VStack(alignment: .leading, spacing: 12) {
      if model.cards.isEmpty {
        Text("当前账号没有可用卡片。")
          .foregroundStyle(.secondary)
      } else {
        Text("选择要登录的 Aime")
          .font(.headline)
        ForEach(model.cards) { card in
          Button {
            Task { await model.login(card: card) }
          } label: {
            HStack {
              VStack(alignment: .leading, spacing: 4) {
                Text(card.label)
                  .font(.headline)
                Text("尾号 \(card.accessCode.suffix(4))")
                  .font(.caption.monospaced())
                  .foregroundStyle(.secondary)
              }
              Spacer()
              Image(systemName: "arrow.right")
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
          }
          .buttonStyle(.bordered)
        }
      }
    }
  }

  private var successView: some View {
    VStack(spacing: 12) {
      Image(systemName: "checkmark.circle.fill")
        .font(.system(size: 52))
        .foregroundStyle(.green)
      Text("登录成功")
        .font(.title2.weight(.semibold))
      Text("可以开始游戏了。")
        .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 36)
  }

  private var failedView: some View {
    VStack(alignment: .leading, spacing: 14) {
      Label("无法进入机台会话", systemImage: "exclamationmark.triangle.fill")
        .font(.headline)
        .foregroundStyle(.orange)
      Text(model.errorMessage ?? "请重新碰一下 NFC 或重新扫描二维码。")
        .foregroundStyle(.secondary)
      if let url = model.webFallbackURL {
        Button("使用网页版继续") { openURL(url) }
          .buttonStyle(.borderedProminent)
      }
    }
  }
}
