cask "imonitor" do
  version "0.4.0"
  sha256 "2b0ecd6ec0df1e494a8ed353f173978d8d2770ebd15b5aa46137268df26cd2ba"

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
end
