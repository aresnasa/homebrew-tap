cask "imonitor" do
  version "0.3.0"
  sha256 "f86c10d144eacf8a4f0cdf954d5bfacfb60ebb23353e60a7457fc56f083f36b2"

  url "https://github.com/aresnasa/iMonitor/releases/download/v0.3.0/iMonitor-v0.3.0.zip"
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
