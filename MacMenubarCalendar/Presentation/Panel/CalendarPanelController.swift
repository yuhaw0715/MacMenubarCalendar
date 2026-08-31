import AppKit
import SwiftUI
import Combine

@MainActor
public final class CalendarPanelController: NSObject, NSWindowDelegate {
    private let viewModel: CalendarViewModel
    private let preferencesStore: PreferencesStoreProtocol
    private var panel: CalendarPanel?
    private var globalClickMonitor: Any?
    private var cancellables = Set<AnyCancellable>()

    public init(viewModel: CalendarViewModel, preferencesStore: PreferencesStoreProtocol = AppPreferencesStore.shared) {
        self.viewModel = viewModel
        self.preferencesStore = preferencesStore
        super.init()
        setupPanel()
        bindViewModel()
    }

    private func setupPanel() {
        let width = preferencesStore.windowWidth
        let height = preferencesStore.windowHeight
        let initialRect = NSRect(x: 0, y: 0, width: width, height: height)

        let newPanel = CalendarPanel(contentRect: initialRect)
        newPanel.delegate = self
        newPanel.isPinned = viewModel.isPinned

        let hostingView = NSHostingView(rootView: CalendarRootView(viewModel: viewModel))
        newPanel.contentView = hostingView

        newPanel.onResignKey = { [weak self] in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                if !self.viewModel.isPinned {
                    self.hidePanel()
                }
            }
        }

        self.panel = newPanel
    }

    private func bindViewModel() {
        viewModel.$isPinned
            .sink { [weak self] pinned in
                self?.panel?.isPinned = pinned
                if pinned {
                    self?.removeGlobalMonitor()
                } else if self?.panel?.isVisible == true {
                    self?.setupGlobalMonitor()
                }
            }
            .store(in: &cancellables)
    }

    public var isVisible: Bool {
        panel?.isVisible ?? false
    }

    public func toggle(relativeTo statusButton: NSStatusBarButton?) {
        if isVisible {
            hidePanel()
        } else {
            show(relativeTo: statusButton)
        }
    }

    public func show(relativeTo statusButton: NSStatusBarButton?) {
        guard let panel = panel else { return }

        viewModel.onPanelOpen()

        if let button = statusButton, let window = button.window {
            let buttonRectInWindow = button.convert(button.bounds, to: nil)
            let buttonRectOnScreen = window.convertToScreen(buttonRectInWindow)

            let screen = window.screen ?? NSScreen.main ?? NSScreen.screens[0]
            let screenFrame = screen.visibleFrame

            var panelX = buttonRectOnScreen.midX - (panel.frame.width / 2)
            // Clamp to screen bounds
            if panelX < screenFrame.minX {
                panelX = screenFrame.minX + 8
            } else if panelX + panel.frame.width > screenFrame.maxX {
                panelX = screenFrame.maxX - panel.frame.width - 8
            }

            let panelY = buttonRectOnScreen.minY - panel.frame.height - 4

            panel.setFrameOrigin(NSPoint(x: panelX, y: panelY))
        }

        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        if !viewModel.isPinned {
            setupGlobalMonitor()
        }
    }

    public func hidePanel() {
        removeGlobalMonitor()
        panel?.orderOut(nil)
    }

    private func setupGlobalMonitor() {
        removeGlobalMonitor()
        globalClickMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseDown, .rightMouseDown]
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                if !self.viewModel.isPinned && self.isVisible {
                    self.hidePanel()
                }
            }
        }
    }

    private func removeGlobalMonitor() {
        if let monitor = globalClickMonitor {
            NSEvent.removeMonitor(monitor)
            globalClickMonitor = nil
        }
    }

    // MARK: - NSWindowDelegate

    public func windowDidResize(_ notification: Notification) {
        guard let panel = panel else { return }
        preferencesStore.windowWidth = Double(panel.frame.width)
        preferencesStore.windowHeight = Double(panel.frame.height)
    }
}
