class Zap < Formula
  desc "CLI for downloading video and audio with Zap"
  homepage "https://github.com/egeuysall/zap"
  version "0.1.3"

  livecheck do
    url :stable
    strategy :github_latest
  end

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/egeuysall/zap/releases/download/v0.1.3/zap-darwin-arm64"
      sha256 "2e394db70b03f597092bd2bb10199c0843ccc14e1efacb02f9a802a4dcbb4506"
    else
      url "https://github.com/egeuysall/zap/releases/download/v0.1.3/zap-darwin-x64"
      sha256 "3d2fb925d534c8e4d8a614ae8aa1ee55afdda5b509372a7f39d3286ed48d7aab"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/egeuysall/zap/releases/download/v0.1.3/zap-linux-arm64"
      sha256 "ff83bb7cc4076e2a79c05176385b57c86a126f2d6a7e91b5b02573547b139379"
    else
      url "https://github.com/egeuysall/zap/releases/download/v0.1.3/zap-linux-x64"
      sha256 "15e22c217eca406c2a02baeb5efdb4b2c24af93fdb3ad727e262d52787eaa3f4"
    end
  end

  def install
    bin.install Dir["zap-*"].first => "zap"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/zap --version")
  end
end
