cask "imonitor" do
  version "0.5.8"
  sha256 "bd1fe82b8e889ea3196d34ddce9772ef3b02d444ab52b37ab4233fea377c2967"

  url "https://github.com/aresnasa/iMonitor/releases/download/v#{version}/iMonitor-0.5.8.dmg"
  name "iMonitor"
  desc "Menu bar system monitor – CPU, Memory, GPU, Network"
  homepage "https://github.com/aresnasa/iMonitor"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: :big_sur

  app "iMonitor.app"

  postflight do
    # 1. Strip extended attributes (removes quarantine flag)
    system_command "/usr/bin/xattr",
                   args: ["-cr", "#{appdir}/iMonitor.app"],
                   sudo: false

    # 2. Re-sign nested frameworks / dylibs with ad-hoc identity.
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

    # 3. Re-sign the main app bundle with ad-hoc identity + entitlements.
    #    The build-machine signature is invalidated when Homebrew copies the
    #    .app; without re-signing macOS 14+ / Sequoia blocks the app.
    ent = "#{appdir}/iMonitor.app/Contents/Resources/iMonitor-adhoc.entitlements"
    codesign_args = ["--force", "--sign", "-", "--timestamp=none"]
    codesign_args += ["--entitlements", ent] if File.exist?(ent)
    codesign_args << "#{appdir}/iMonitor.app"
    system_command "/usr/bin/codesign",
                   args: codesign_args,
                   sudo: false

    # 4. Touch the bundle so Launch Services picks up the new signature.
    system_command "/usr/bin/touch",
                   args: ["#{appdir}/iMonitor.app"],
                   sudo: false
  end

  zap trash: [
    "~/Library/Caches/com.aresnasa.iMonitor",
    "~/Library/Preferences/com.aresnasa.iMonitor.plist",
  ]
end
