import Foundation

public enum AuthorizationStatus: String, Sendable, Codable {
    case notDetermined
    case restricted
    case denied
    case authorized

    public var isAuthorized: Bool {
        self == .authorized
    }
}
