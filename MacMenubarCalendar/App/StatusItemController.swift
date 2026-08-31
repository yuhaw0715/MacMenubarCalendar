import AppKit
import Combine

@MainActor
public final class StatusItemController: NSObject, NSMenuDelegate {
    private let statusItem: NSStatusItem
    private let viewModel: CalendarViewModel
    private let panelController: CalendarPanelController
    private var cancellables = Set<AnyCancellable>()

    public init(viewModel: CalendarViewModel, panelController: CalendarPanelController) {
        self.viewModel = viewModel
        self.panelController = panelController
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        super.init()
        setupStatusItem()
        bindViewModel()
    }

    private func setupStatusItem() {
        guard let button = statusItem.button else { return }

        button.target = self
        button.action = #selector(statusItemClicked(_:))
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        updateButtonTitle(viewModel.todayDateNumber)
    }

    private func bindViewModel() {
        viewModel.$todayDateNumber
            .sink { [weak self] dayNumber in
                self?.updateButtonTitle(dayNumber)
            }
            .store(in: &cancellables)
    }

    private func updateButtonTitle(_ dayNumber: String) {
        guard let button = statusItem.button else { return }
        let title = dayNumber.isEmpty ? "\(Calendar.current.component(.day, from: Date()))" : dayNumber

        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedDigitSystemFont(ofSize: 13, weight: .semibold)
        ]
        button.attributedTitle = NSAttributedString(string: title, attributes: attributes)
        button.toolTip = "Mac Menubar Calendar"
        button.setAccessibilityLabel("Mac Menubar Calendar, 今日: \(title)")
    }

    @objc private func statusItemClicked(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent

        if event?.type == .rightMouseUp {
            showContextMenu(sender)
        } else {
            panelController.toggle(relativeTo: statusItem.button)
        }
    }

    private func showContextMenu(_ sender: NSStatusBarButton) {
        let menu = NSMenu()

        let openItem = NSMenuItem(title: NSLocalizedString("action.open_in_calendar", comment: "開啟月曆"), action: #selector(openCalendarAction), keyEquivalent: "")
        openItem.target = self
        menu.addItem(openItem)

        let refreshItem = NSMenuItem(title: NSLocalizedString("header.action.refresh", comment: "重新整理"), action: #selector(refreshAction), keyEquivalent: "r")
        refreshItem.target = self
        menu.addItem(refreshItem)

        let settingsItem = NSMenuItem(title: NSLocalizedString("settings.title", comment: "偏好設定"), action: #selector(openSettingsAction), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: NSLocalizedString("action.quit", comment: "結束 App"), action: #selector(quitAction), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        // Reset menu back to nil so left click continues to trigger custom panel
        DispatchQueue.main.async { [weak self] in
            self?.statusItem.menu = nil
        }
    }

    @objc private func openCalendarAction() {
        panelController.show(relativeTo: statusItem.button)
    }

    @objc private func refreshAction() {
        Task {
            await viewModel.refreshData()
        }
    }

    @objc private func openSettingsAction() {
        viewModel.isShowingSettings = true
        panelController.show(relativeTo: statusItem.button)
    }

    @objc private func quitAction() {
        NSApplication.shared.terminate(nil)
    }
}
