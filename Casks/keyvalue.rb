cask "keyvalue" do
  version "0.1.8"
  sha256 "47fd283cc61bd9cd9652f72bb2d35218f918b8336993406071277c0fb46574c2"

  url "https://github.com/aresnasa/mac-keyvalue/releases/download/v#{version}/KeyValue-#{version}-universal.dmg"
  name "KeyValue"
  desc "KV - Secure password & key-value manager"
  homepage "https://github.com/aresnasa/mac-keyvalue"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: :ventura

  app "KeyValue.app"

  postflight_steps do
    run "/bin/zsh",
        args: ["-c", <<~SH]
          app="{{appdir}}/KeyValue.app"

          # 1. Strip extended attributes (removes quarantine flag)
          /usr/bin/xattr -cr "$app"

          # 2. Re-sign nested frameworks / dylibs / bundles with ad-hoc identity.
          #    Skip .bundle dirs that lack Info.plist (not real signable bundles,
          #    e.g. swift-crypto_Crypto.bundle only contains PrivacyInfo.xcprivacy).
          for nested in "$app"/Contents/**/*.framework(N) "$app"/Contents/**/*.dylib(N); do
            /usr/bin/codesign --force --sign - --timestamp=none "$nested"
          done
          for nested in "$app"/Contents/**/*.bundle(N); do
            [[ -f "$nested/Info.plist" ]] || continue
            /usr/bin/codesign --force --sign - --timestamp=none "$nested"
          done

          # 3. Re-sign the main app bundle with ad-hoc identity + entitlements.
          #    The build-machine signature is invalidated when Homebrew copies the
          #    .app; without re-signing macOS 14+ / Sequoia blocks the app.
          ent="$app/Contents/Resources/MacKeyValue-adhoc.entitlements"
          if [[ -f "$ent" ]]; then
            /usr/bin/codesign --force --sign - --timestamp=none --entitlements "$ent" "$app"
          else
            /usr/bin/codesign --force --sign - --timestamp=none "$app"
          fi

          # 4. Touch the bundle so Launch Services picks up the new signature.
          /usr/bin/touch "$app"
        SH
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
