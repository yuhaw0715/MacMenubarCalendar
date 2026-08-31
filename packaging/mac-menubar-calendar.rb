cask "mac-menubar-calendar" do
  version "1.0.0"
  sha256 :no_check # Replace with release SHA-256 upon GitHub Release tag creation

  url "https://github.com/yuhaw0715/MacMenubarCalendar/releases/download/v#{version}/MacMenubarCalendar.zip"
  name "Mac Menubar Calendar"
  desc "Lightweight native macOS menu bar calendar viewer"
  homepage "https://github.com/yuhaw0715/MacMenubarCalendar"

  depends_on macos: ">= :sequoia"
  depends_on arch: :arm64

  app "Mac Menubar Calendar.app"

  zap trash: [
    "~/Library/Containers/com.yuhaw0715.MacMenubarCalendar",
    "~/Library/Preferences/com.yuhaw0715.MacMenubarCalendar.plist",
  ]
end
