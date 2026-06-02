cask "imonitor" do
  version "0.3.0"
  sha256 "901804ba84b1766a1c902df8fd922dd810cf8abe6a3addeca6100a98f88df365"

  url "https://github.com/aresnasa/iMonitor/releases/download/v#{version}/iMonitor-v#{version}.zip"
  name "iMonitor"
  desc "macOS menu bar system monitor - CPU, Memory, GPU, Network"
  homepage "https://github.com/aresnasa/iMonitor"

  depends_on macos: ">= :big_sur"

  app "iMonitor.app"

  zap trash: [
    "~/Library/Caches/com.aresnasa.iMonitor",
    "~/Library/Preferences/com.aresnasa.iMonitor.plist",
  ]
end
