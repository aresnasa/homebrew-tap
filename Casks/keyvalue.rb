cask "keyvalue" do
  version "0.1.0"
  sha256 "95af1ed142ffebd11ba3e6a9d7e9608f080b8772b39480ed8fb12a62c8991c2f"

  url "https://github.com/aresnasa/mac-keyvalue/releases/download/v#{version}/KeyValue-#{version}-apple-silicon.dmg"
  name "KeyValue"
  desc "K🔒V — Secure password & key-value manager for macOS"
  homepage "https://github.com/aresnasa/mac-keyvalue"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: ">= :ventura"

  app "KeyValue.app"

  postflight do
    # Remove quarantine attribute for ad-hoc signed app
    system_command "/usr/bin/xattr",
                   args: ["-cr", "#{appdir}/KeyValue.app"],
                   sudo: false
  end

  zap trash: [
    "~/Library/Application Support/com.aresnasa.mackeyvalue",
    "~/Library/Preferences/com.aresnasa.mackeyvalue.plist",
    "~/Library/Caches/com.aresnasa.mackeyvalue",
  ]

  caveats <<~EOS
    KeyValue requires two system permissions for keyboard simulation:

      1. Accessibility: System Settings → Privacy & Security → Accessibility
      2. Input Monitoring: System Settings → Privacy & Security → Input Monitoring

    The app will guide you through the setup on first launch.

    Since this is an ad-hoc signed open-source app, if macOS blocks it:
      xattr -cr /Applications/KeyValue.app
  EOS
end

