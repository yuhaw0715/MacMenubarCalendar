import SwiftUI

public struct PermissionPromptView: View {
    let status: AuthorizationStatus
    let onRequestAccess: () -> Void
    let onOpenSettings: () -> Void

    public init(
        status: AuthorizationStatus,
        onRequestAccess: @escaping () -> Void,
        onOpenSettings: @escaping () -> Void
    ) {
        self.status = status
        self.onRequestAccess = onRequestAccess
        self.onOpenSettings = onOpenSettings
    }

    public var body: some View {
        VStack(spacing: 20) {
            Spacer()

            if status == .notDetermined {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 48))
                    .foregroundColor(.accentColor)

                Text(AppStrings.localized("permission.welcome.title"))
                    .font(.title2)
                    .fontWeight(.bold)

                Text(AppStrings.localized("permission.welcome.description"))
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)

                Button(action: onRequestAccess) {
                    Text(AppStrings.localized("permission.grant_button"))
                        .font(.body)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
            } else {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.orange)

                Text(AppStrings.localized("permission.denied.title"))
                    .font(.title2)
                    .fontWeight(.bold)

                Text(AppStrings.localized("permission.denied.description"))
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)

                Button(action: onOpenSettings) {
                    Text(AppStrings.localized("permission.open_settings_button"))
                        .font(.body)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
            }

            Spacer()
        }
        .padding(30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
