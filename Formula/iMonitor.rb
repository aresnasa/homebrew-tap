class Imonitor < Formula
  desc "macOS menu bar system monitor - CPU, Memory, GPU, Network"
  homepage "https://github.com/aresnasa/iMonitor"
  url "https://github.com/aresnasa/iMonitor/releases/download/v0.3.0/iMonitor-v0.3.0.zip"
  sha256 "901804ba84b1766a1c902df8fd922dd810cf8abe6a3addeca6100a98f88df365"
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
