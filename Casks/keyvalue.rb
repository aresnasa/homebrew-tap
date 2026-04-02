cask "keyvalue" do
  version "0.1.3"
  sha256 "1d855f75c3697ef9501ebc2e467773938acc3028609b48f4b1cb2614ebe00d59"

  url "https://github.com/aresnasa/mac-keyvalue/releases/download/v#{version}/KeyValue-#{version}-universal.dmg"
  name "KeyValue"
  desc "KV - Secure password & key-value manager"
  homepage "https://github.com/aresnasa/mac-keyvalue"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: ">= :ventura"

  app "KeyValue.app"

  postflight do
    # 1. Strip extended attributes (removes quarantine flag)
    system_command "/usr/bin/xattr",
                   args: ["-cr", "#{appdir}/KeyValue.app"],
                   sudo: false

    # 2. Re-sign nested frameworks / dylibs with ad-hoc identity.
    #    Skip .bundle dirs that lack Info.plist (not real signable bundles,
    #    e.g. swift-crypto_Crypto.bundle only contains PrivacyInfo.xcprivacy).
    Dir.glob("#{appdir}/KeyValue.app/Contents/**/*.{framework,dylib}").each do |nested|
      system_command "/usr/bin/codesign",
                     args: ["--force", "--sign", "-", "--timestamp=none", nested],
                     sudo: false
    end
    Dir.glob("#{appdir}/KeyValue.app/Contents/**/*.bundle").each do |nested|
      next unless File.exist?(File.join(nested, "Info.plist"))

      system_command "/usr/bin/codesign",
                     args: ["--force", "--sign", "-", "--timestamp=none", nested],
                     sudo: false
    end

    # 3. Re-sign the main app bundle with ad-hoc identity + entitlements.
    #    The build-machine signature is invalidated when Homebrew copies the
    #    .app; without re-signing macOS 14+ / Sequoia blocks the app.
    ent = "#{appdir}/KeyValue.app/Contents/Resources/MacKeyValue-adhoc.entitlements"
    codesign_args = ["--force", "--sign", "-", "--timestamp=none"]
    codesign_args += ["--entitlements", ent] if File.exist?(ent)
    codesign_args << "#{appdir}/KeyValue.app"
    system_command "/usr/bin/codesign",
                   args: codesign_args,
                   sudo: false

    # 4. Touch the bundle so Launch Services picks up the new signature.
    system_command "/usr/bin/touch",
                   args: ["#{appdir}/KeyValue.app"],
                   sudo: false
  end

  zap trash: [
    "~/Library/Application Support/com.aresnasa.mackeyvalue",
    "~/Library/Caches/com.aresnasa.mackeyvalue",
    "~/Library/Preferences/com.aresnasa.mackeyvalue.plist",
  ]

  caveats <<~EOS
    KeyValue requires two system permissions for keyboard simulation:

      1. Accessibility: System Settings → Privacy & Security → Accessibility
      2. Input Monitoring: System Settings → Privacy & Security → Input Monitoring

    The app will guide you through the setup on first launch.

    If macOS blocks the app after install or upgrade, run:
      xattr -cr /Applications/KeyValue.app
      codesign --force --sign - --timestamp=none /Applications/KeyValue.app
  EOS
end
