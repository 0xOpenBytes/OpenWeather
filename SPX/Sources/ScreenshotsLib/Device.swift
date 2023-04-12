import Foundation
import Sh

enum Device: CaseIterable {
  case proMax

  var simulatorName: String {
    switch self {
    case .proMax:
      return "iPhone 14 Pro Max"
    }
  }

  var name: String {
    switch self {
    case .proMax:
      return "ProMax"
    }
  }

  static func createAllMasks(at masksPath: String) throws {
    try Self.allCases.forEach { try $0.createMask(at: masksPath) }
  }
  
  func createMask(at masksPath: String) throws {
    try sh(.terminal, "xcrun simctl bootstatus '\(self.simulatorName)' -b")
    try sh(.terminal, "xcrun simctl io '\(self.simulatorName)' screenshot \(masksPath)/\(self.name)-masked.png --type png --mask alpha")
    try sh(.terminal, "xcrun simctl shutdown '\(self.simulatorName)'")
  }
}
