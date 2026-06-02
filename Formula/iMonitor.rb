class Imonitor < Formula
  desc "macOS menu bar system monitor - CPU, Memory, GPU, Network"
  homepage "https://github.com/aresnasa/iMonitor"
  url "https://github.com/aresnasa/iMonitor/releases/download/v0.3.0/iMonitor-v0.3.0.zip"
  sha256 "59105a2b302613688e7b7ec177c3a291390c166ce6a643169196f4f7d8b70c7e"
  version "0.3.0"

  depends_on :macos => :big_sur

  def install
    prefix.install "iMonitor.app"
  end

  def caveats
    <<~EOS
      iMonitor has been installed to #{prefix}/iMonitor.app
      You may want to move it to /Applications manually:
        mv #{prefix}/iMonitor.app /Applications/
    EOS
  end
end
