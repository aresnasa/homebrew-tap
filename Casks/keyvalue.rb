cask "keyvalue" do
  version "0.1.1"

  on_arm do
    sha256 "06feccc1c3bc339d197ffcae5b204c1a9c8603c3698780f7f0596d7fb4d3e0d3"
    url "https://github.com/aresnasa/mac-keyvalue/releases/download/v#{version}/KeyValue-#{version}-apple-silicon.dmg"
  end
  on_intel do
    sha256 "06feccc1c3bc339d197ffcae5b204c1a9c8603c3698780f7f0596d7fb4d3e0d3"
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
    system_command "/usr/bin/xattr",
                   args: ["-cr", "#{appdir}/KeyValue.app"],
                   sudo: false

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

    ent = "#{appdir}/KeyValue.app/Contents/Resources/MacKeyValue-adhoc.entitlements"
    codesign_args = ["--force", "--sign", "-", "--timestamp=none"]
    codesign_args += ["--entitlements", ent] if File.exist?(ent)
    codesign_args << "#{appdir}/KeyValue.app"
    system_command "/usr/bin/codesign",
                   args: codesign_args,
                   sudo: false

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
      codesign --force --sign - --timestamp=none /Applications/KeyValue.app
  EOS
end

