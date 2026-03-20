cask "keyvalue" do
  version "0.1.1"
  sha256 "b5103843392b869d99ee68cfbff5d923ced2b974e60bb9779929f380f84ded25"

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

