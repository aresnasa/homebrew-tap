cask "imonitor" do
  version "0.4.1"
  sha256 "42e0353060d04426d908ff5b389469756f73bce1bf0560f45e6078d0b9d35896"

  url "https://github.com/aresnasa/iMonitor/releases/download/v#{version}/iMonitor-#{version}.dmg"
  name "iMonitor"
  desc "macOS menu bar system monitor – CPU, Memory, GPU, Network"
  homepage "https://github.com/aresnasa/iMonitor"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: ">= :big_sur"

  app "iMonitor.app"

  postflight do
    # Strip extended attributes (removes quarantine flag)
    system_command "/usr/bin/xattr",
                   args: ["-cr", "#{appdir}/iMonitor.app"],
                   sudo: false

    # Re-sign nested frameworks / dylibs with ad-hoc identity.
    Dir.glob("#{appdir}/iMonitor.app/Contents/**/*.{framework,dylib}").each do |nested|
      system_command "/usr/bin/codesign",
                     args: ["--force", "--sign", "-", "--timestamp=none", nested],
                     sudo: false
    end
    Dir.glob("#{appdir}/iMonitor.app/Contents/**/*.bundle").each do |nested|
      next unless File.exist?(File.join(nested, "Info.plist"))

      system_command "/usr/bin/codesign",
                     args: ["--force", "--sign", "-", "--timestamp=none", nested],
                     sudo: false
    end

    # Re-sign the main app with ad-hoc identity (no entitlements).
    # The build-machine signature is invalidated when Homebrew copies
    # the .app; without re-signing macOS blocks the app.
    system_command "/usr/bin/codesign",
                   args: ["--force", "--sign", "-", "--timestamp=none", "#{appdir}/iMonitor.app"],
                   sudo: false

    # Touch the bundle so Launch Services picks up the new signature.
    system_command "/usr/bin/touch",
                   args: ["#{appdir}/iMonitor.app"],
                   sudo: false
  end

  zap trash: [
    "~/Library/Caches/com.aresnasa.iMonitor",
    "~/Library/Preferences/com.aresnasa.iMonitor.plist",
  ]
end
