import Foundation

enum InvocationParser {
  static let host = "link.neri.moe"

  static func machinePublicId(from url: URL) -> String? {
    guard url.scheme?.lowercased() == "https",
          url.host?.lowercased() == host else {
      return nil
    }

    let components = url.path.split(separator: "/", omittingEmptySubsequences: true)
    guard components.count == 2, components[0] == "t" else {
      return nil
    }

    let value = String(components[1]).removingPercentEncoding ?? String(components[1])
    guard !value.isEmpty, value.count <= 80,
          value.allSatisfy({ $0.isLetter || $0.isNumber || $0 == "-" || $0 == "_" }) else {
      return nil
    }
    return value
  }
}
