cask "keyvalue" do
  version "0.1.1"

  on_arm do
    sha256 "d98fdb8e885c828aead32218a1acb4e3d3b2fb5acba0c76c5fa276dbcaac48a6"
    url "https://github.com/aresnasa/mac-keyvalue/releases/download/v#{version}/KeyValue-#{version}-apple-silicon.dmg"
  end
  on_intel do
    sha256 "d98fdb8e885c828aead32218a1acb4e3d3b2fb5acba0c76c5fa276dbcaac48a6"
    url "https://github.com/aresnasa/mac-keyvalue/releases/download/v#{version}/KeyValue-#{version}-intel.dmg"
  end

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
    # 1. Strip ALL extended attributes (including quarantine)
    system_command "/usr/bin/xattr",
                   args: ["-cr", "#{appdir}/KeyValue.app"],
                   sudo: false

    # 2. Re-sign nested frameworks / dylibs with ad-hoc identity
    Dir.glob("#{appdir}/KeyValue.app/Contents/**/*.{framework,dylib,bundle}").each do |nested|
      system_command "/usr/bin/codesign",
                     args: ["--force", "--sign", "-", "--timestamp=none", nested],
                     sudo: false
    end

    # 3. Re-sign the main app bundle with ad-hoc identity.
    #    This is critical: the original ad-hoc signature from the build
    #    machine is invalidated when Homebrew copies the .app to
    #    /Applications.  Without re-signing, macOS 14+ / Sequoia / Tahoe
    #    will block the app with "Apple cannot verify".
    ent = "#{appdir}/KeyValue.app/Contents/Resources/MacKeyValue-adhoc.entitlements"
    codesign_args = ["--force", "--sign", "-", "--timestamp=none", "--deep"]
    codesign_args += ["--entitlements", ent] if File.exist?(ent)
    codesign_args << "#{appdir}/KeyValue.app"
    system_command "/usr/bin/codesign",
                   args: codesign_args,
                   sudo: false

    # 4. Touch the bundle so Launch Services picks up the change
    system_command "/usr/bin/touch",
                   args: ["#{appdir}/KeyValue.app"],
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

    If macOS blocks the app after install or upgrade, run:
      xattr -cr /Applications/KeyValue.app
      codesign --force --sign - --timestamp=none --deep /Applications/KeyValue.app
  EOS
end

