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
        updateStatusItemIcon(date: viewModel.currentDate, language: viewModel.appLanguage)
    }

    private func bindViewModel() {
        Publishers.CombineLatest(viewModel.$currentDate, viewModel.$appLanguage)
            .sink { [weak self] date, language in
                self?.updateStatusItemIcon(date: date, language: language)
                DynamicAppIconController.shared.updateIcon(forceDate: date, forceLanguage: language)
            }
            .store(in: &cancellables)
    }

    private func updateStatusItemIcon(date: Date, language: AppLanguage) {
        guard let button = statusItem.button else { return }

        let image = MenubarIconRenderer.createStackedIcon(
            date: date,
            calendar: viewModel.calendar,
            language: language
        )

        button.image = image
        button.imagePosition = .imageOnly
        button.title = ""
        button.attributedTitle = NSAttributedString()

        let isZh = language.isChinese()
        let monthNumber = viewModel.calendar.component(.month, from: date)
        let dayNumber = viewModel.calendar.component(.day, from: date)

        let dateDesc = isZh ? "\(monthNumber)月\(dayNumber)日" : "\(date.formatted(.dateTime.month().day()))"
        button.toolTip = "Mac Menubar Calendar (\(dateDesc))"
        button.setAccessibilityLabel("Mac Menubar Calendar, \(dateDesc)")
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

        let openItem = NSMenuItem(title: AppStrings.localized("action.open_in_calendar"), action: #selector(openCalendarAction), keyEquivalent: "")
        openItem.target = self
        menu.addItem(openItem)

        let refreshItem = NSMenuItem(title: AppStrings.localized("header.action.refresh"), action: #selector(refreshAction), keyEquivalent: "r")
        refreshItem.target = self
        menu.addItem(refreshItem)

        let settingsItem = NSMenuItem(title: AppStrings.localized("settings.title"), action: #selector(openSettingsAction), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: AppStrings.localized("action.quit"), action: #selector(quitAction), keyEquivalent: "q")
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
