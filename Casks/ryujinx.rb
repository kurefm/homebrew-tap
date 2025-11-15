cask "ryujinx" do
  version "1.3.3"
  sha256 "e4818bb84c98e0d3120691821e90772099e46101273d3f145ffdb10eee2c0dbb"

  url "https://git.ryujinx.app/api/v4/projects/1/packages/generic/Ryubing/#{version}/ryujinx-#{version}-macos_universal.app.tar.gz",
    verified: "https://git.ryujinx.app/api/v4/projects/1/packages/generic/Ryubing/"

  name "Ryujinx"
  desc "Nintendo Switch 1 emulator written in C#"
  homepage "https://ryujinx.app/"

  auto_updates true
  depends_on macos: ">= :big_sur"

  app "Ryujinx.app"

  zap trash: [
    "~/Library/Application Support/Ryujinx",
    "~/Library/Application Support/CrashReporter/Ryujinx_*.plist",
    "~/Library/Preferences/org.ryujinx.Ryujinx.plist",
    "~/Library/Saved Application State/org.ryujinx.Ryujinx.savedState",
  ]
end
