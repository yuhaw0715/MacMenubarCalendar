import AppKit
import SwiftUI

public final class AppDelegate: NSObject, NSApplicationDelegate {
    public var viewModel: CalendarViewModel?
    public var panelController: CalendarPanelController?
    public var statusItemController: StatusItemController?

    public func applicationDidFinishLaunching(_ notification: Notification) {
        // Enforce accessory activation policy so no Dock icon is shown
        NSApp.setActivationPolicy(.accessory)

        let calendarService = EventKitCalendarService()
        let vm = CalendarViewModel(calendarService: calendarService)
        let panelCtrl = CalendarPanelController(viewModel: vm)
        let statusCtrl = StatusItemController(viewModel: vm, panelController: panelCtrl)

        self.viewModel = vm
        self.panelController = panelCtrl
        self.statusItemController = statusCtrl
    }
}
