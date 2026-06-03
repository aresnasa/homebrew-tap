cask "imonitor" do
  version "0.3.1"
  sha256 "54d50b1047b4405ed931ca91cb0f0288e4a47a33087c4cbe4f24e7cb800fd76b"

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
    system_command "/usr/bin/xattr",
                   args: ["-cr", "#{appdir}/iMonitor.app"],
                   sudo: false

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

    ent = "#{appdir}/iMonitor.app/Contents/Resources/iMonitor-adhoc.entitlements"
    codesign_args = ["--force", "--sign", "-", "--timestamp=none"]
    codesign_args += ["--entitlements", ent] if File.exist?(ent)
    codesign_args << "#{appdir}/iMonitor.app"
    system_command "/usr/bin/codesign",
                   args: codesign_args,
                   sudo: false

    system_command "/usr/bin/touch",
                   args: ["#{appdir}/iMonitor.app"],
                   sudo: false
  end

  zap trash: [
    "~/Library/Caches/com.aresnasa.iMonitor",
    "~/Library/Preferences/com.aresnasa.iMonitor.plist",
  ]

  caveats <<~EOS
    If macOS blocks the app after install or upgrade, run:
      xattr -cr /Applications/iMonitor.app
      codesign --force --sign - --timestamp=none /Applications/iMonitor.app
  EOS
end
