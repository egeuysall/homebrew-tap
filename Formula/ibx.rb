class Ibx < Formula
  desc "CLI for capturing thoughts and todos with IBX"
  homepage "https://ibx.egeuysal.com"
  url "https://github.com/egeuysall/ibx/releases/download/v0.3.6/ibx"
  version "0.3.6"
  sha256 "d752d83599682a07a8400adbc048afa7f202f1c36d76333b9cfb6fbeb0fa2a4e"
  livecheck do
    url "https://github.com/egeuysall/ibx/releases"
    strategy :github_latest
  end

  depends_on "node"

  def install
    bin.install "ibx"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ibx --version")
  end
end
