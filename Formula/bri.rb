class Bri < Formula
  desc "CLI for publishing Markdown to Bri"
  homepage "https://bri.fyi"
  version "2.1.37"
  license "GPL-3.0-only"

  livecheck do
    url :stable
    strategy :github_latest
  end

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/egeuysall/bri/releases/download/v2.1.37/bri-darwin-arm64"
      sha256 "13641009fe1056f8ca682178e0637d79e1f5d0ac91db8c50e48269058bf9ed8f"
    else
      url "https://github.com/egeuysall/bri/releases/download/v2.1.37/bri-darwin-x64"
      sha256 "646b17e3d3a42b91386613c162761cd43e8413f846b0900acfbdd9ae3161452b"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/egeuysall/bri/releases/download/v2.1.37/bri-linux-arm64"
      sha256 "18f5f883c0c298bd9679517b0035acafd1584e1f361a1ee7a08efd5466c2f3ed"
    else
      url "https://github.com/egeuysall/bri/releases/download/v2.1.37/bri-linux-x64"
      sha256 "0cfb4d4d186370f1170cb08f592d27ceb71730d7a89b83cbd89969109cc8522f"
    end
  end

  def install
    bin.install Dir["bri-*"].first => "bri"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/bri --version")
  end
end
