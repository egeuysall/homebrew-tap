class Zap < Formula
  desc "CLI for downloading video and audio with Zap"
  homepage "https://github.com/egeuysall/zap"
  version "0.1.4"

  livecheck do
    url :stable
    strategy :github_latest
  end

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/egeuysall/zap/releases/download/v0.1.4/zap-darwin-arm64"
      sha256 "e51c619416ea8affeba950aae675a0fa92233bbcdb39ea1b89001ae88251b791"
    else
      url "https://github.com/egeuysall/zap/releases/download/v0.1.4/zap-darwin-x64"
      sha256 "83b6e3d04b462702a076b1751d02f260a4931a4533a1099347827f9705dae946"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/egeuysall/zap/releases/download/v0.1.4/zap-linux-arm64"
      sha256 "e69e1b58f2bf9642f72c6bbb4507b20aac0237c6ece43065bac047f1bcc8926e"
    else
      url "https://github.com/egeuysall/zap/releases/download/v0.1.4/zap-linux-x64"
      sha256 "590c9035a5835318fe8230baaf6c7cdf8bdcf238b6b9ef01b6ee4907af5ab080"
    end
  end

  def install
    bin.install Dir["zap-*"].first => "zap"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/zap --version")
  end
end
