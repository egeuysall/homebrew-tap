#!/usr/bin/env ruby

require "digest"
require "json"
require "net/http"
require "open-uri"
require "pathname"
require "uri"

ROOT = Pathname(__dir__).join("..").realpath
API_ROOT = "https://api.github.com"
USER_AGENT = "egeuysall-homebrew-tap"

FORMULAS = {
  "bri" => {
    class_name: "Bri",
    desc: "CLI for publishing Markdown to Bri",
    homepage: "https://bri.fyi",
    repo: "egeuysall/bri",
    license: "GPL-3.0-only",
    assets: {
      "darwin-arm64" => "bri-darwin-arm64",
      "darwin-x64" => "bri-darwin-x64",
      "linux-arm64" => "bri-linux-arm64",
      "linux-x64" => "bri-linux-x64"
    }
  },
  "ibx" => {
    class_name: "Ibx",
    desc: "CLI for capturing thoughts and todos with IBX",
    homepage: "https://ibx.egeuysal.com",
    repo: "egeuysall/ibx",
    assets: { "portable" => "ibx" }
  },
  "zap" => {
    class_name: "Zap",
    desc: "CLI for downloading video and audio with Zap",
    homepage: "https://github.com/egeuysall/zap",
    repo: "egeuysall/zap",
    assets: {
      "darwin-arm64" => "zap-darwin-arm64",
      "darwin-x64" => "zap-darwin-x64",
      "linux-arm64" => "zap-linux-arm64",
      "linux-x64" => "zap-linux-x64"
    }
  }
}.freeze

def api_get(path)
  uri = URI("#{API_ROOT}/#{path}")
  request = Net::HTTP::Get.new(uri)
  request["Accept"] = "application/vnd.github+json"
  request["User-Agent"] = USER_AGENT
  request["Authorization"] = "Bearer #{ENV["GITHUB_TOKEN"]}" if ENV["GITHUB_TOKEN"]&.match?(/\S/)

  response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
    http.request(request)
  end
  raise "GitHub API #{response.code} for #{path}: #{response.body}" unless response.is_a?(Net::HTTPSuccess)

  JSON.parse(response.body)
end

def asset_sha256(url, headers = {})
  digest = Digest::SHA256.new
  URI.open(url, headers.merge("User-Agent" => USER_AGENT)) do |stream|
    while (chunk = stream.read(1024 * 1024))
      digest.update(chunk)
    end
  end
  digest.hexdigest
end

def sha_from_manifest(url, asset_name)
  contents = URI.open(url, "User-Agent" => USER_AGENT).read
  line = contents.lines.find { |candidate| candidate.split.last == asset_name }
  digest = line&.split&.first
  digest if digest&.match?(/\A[0-9a-f]{64}\z/i)
end

def release_data(repo)
  release = api_get("repos/#{repo}/releases/latest")
  version = release.fetch("tag_name").sub(/\Av/, "")
  raise "invalid release version for #{repo}: #{version}" unless version.match?(/\A\d+\.\d+\.\d+\z/)

  assets = release.fetch("assets").to_h { |asset| [asset.fetch("name"), asset] }
  manifest = assets.values.find { |asset| ["SHA256SUMS", "checksums.txt"].include?(asset["name"]) }
  [version, assets, manifest]
end

def formula_for(name, config, version, assets, manifest)
  checksums = {}
  config[:assets].each_value do |asset_name|
    asset = assets.fetch(asset_name) { raise "#{name} release is missing #{asset_name}" }
    checksum = manifest && sha_from_manifest(manifest.fetch("browser_download_url"), asset_name)
    checksum ||= asset_sha256(asset.fetch("browser_download_url"))
    checksums[asset_name] = checksum
  end

  url_for = lambda do |asset_name|
    "https://github.com/#{config[:repo]}/releases/download/v#{version}/#{asset_name}"
  end

  lines = [
    "class #{config[:class_name]} < Formula",
    "  desc \"#{config[:desc]}\"",
    "  homepage \"#{config[:homepage]}\""
  ]
  lines << "  version \"#{version}\"" unless name == "ibx"
  lines << "  license \"#{config[:license]}\"" if config[:license]

  if name == "ibx"
    lines += [
      "  url \"#{url_for.call("ibx")}\"",
      "  sha256 \"#{checksums.fetch("ibx")}\"",
      "  depends_on \"node\"",
      "",
      "  def install",
      "    bin.install \"ibx\"",
      "  end"
    ]
  else
    asset_prefix = name
    lines += [
      "",
      "  on_macos do",
      "    if Hardware::CPU.arm?",
      "      url \"#{url_for.call(config[:assets].fetch("darwin-arm64"))}\"",
      "      sha256 \"#{checksums.fetch(config[:assets].fetch("darwin-arm64"))}\"",
      "    else",
      "      url \"#{url_for.call(config[:assets].fetch("darwin-x64"))}\"",
      "      sha256 \"#{checksums.fetch(config[:assets].fetch("darwin-x64"))}\"",
      "    end",
      "  end",
      "",
      "  on_linux do",
      "    if Hardware::CPU.arm?",
      "      url \"#{url_for.call(config[:assets].fetch("linux-arm64"))}\"",
      "      sha256 \"#{checksums.fetch(config[:assets].fetch("linux-arm64"))}\"",
      "    else",
      "      url \"#{url_for.call(config[:assets].fetch("linux-x64"))}\"",
      "      sha256 \"#{checksums.fetch(config[:assets].fetch("linux-x64"))}\"",
      "    end",
      "  end",
      "",
      "  def install",
      "    bin.install Dir[\"#{asset_prefix}-*\"].first => \"#{name}\"",
      "  end"
    ]
  end

  lines += [
    "",
    "  test do",
    "    assert_match version.to_s, shell_output(\"" + '#{bin}' + "/#{name} --version\")",
    "  end",
    "",
    "  livecheck do",
    "    url \"https://github.com/#{config[:repo]}/releases\"",
    "    strategy :github_latest",
    "  end",
    "end",
    ""
  ]
  lines.join("\n")
end

FORMULAS.each do |name, config|
  version, assets, manifest = release_data(config[:repo])
  formula = formula_for(name, config, version, assets, manifest)
  path = ROOT.join("Formula", "#{name}.rb")
  path.write(formula)
  puts "updated #{path} to #{version}"
end
