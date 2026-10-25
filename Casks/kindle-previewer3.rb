cask "kindle-previewer3" do
  version "3.107.0"
  sha256 :no_check

  url "https://d2bzeorukaqrvt.cloudfront.net/KindlePreviewerInstaller.pkg"
  name "Kindle Previewer"
  desc "Preview and audit Kindle eBooks"
  homepage "https://kdp.amazon.com/en_US/help/topic/G202131170"

  depends_on :macos

  pkg "KindlePreviewerInstaller.pkg"

  uninstall launchctl: "com.amazon.KindlePreviewerUpdater",
            pkgutil:   "Amazon.Kindle.Previewer.pkg",
            delete:    "/Library/LaunchDaemons/com.amazon.KindlePreviewerUpdater.plist"

  zap trash: "~/.kindle"
end
