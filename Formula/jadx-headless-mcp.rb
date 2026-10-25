class JadxHeadlessMcp < Formula
  desc "Headless MCP server for Android APK static analysis"
  homepage "https://github.com/1013503897/jadx-headless-mcp"
  url "https://github.com/1013503897/jadx-headless-mcp/releases/download/v0.7.1/jadx-headless-mcp-0.7.1-all.jar"
  sha256 "6e5eacf500b64292bfb73c49797c1958f6ee44646e43e868039ae7feb573ff75"
  license "Apache-2.0"

  depends_on "openjdk@21"

  def install
    libexec.install "jadx-headless-mcp-#{version}-all.jar" => "jadx-headless-mcp.jar"
    bin.write_jar_script libexec/"jadx-headless-mcp.jar", "jadx-headless-mcp", "-XX:MaxRAMPercentage=60.0",
                         java_version: "21"
  end

  test do
    require "timeout"

    IO.popen([bin/"jadx-headless-mcp"], "r+") do |io|
      io.puts({
        jsonrpc: "2.0",
        id:      1,
        method:  "initialize",
        params:  {
          protocolVersion: "2024-11-05",
          capabilities:    {},
          clientInfo:      { name: "homebrew", version: "1.0" },
        },
      }.to_json)
      response = JSON.parse(Timeout.timeout(30) { io.gets })
      assert_equal "jadx-headless-mcp", response.dig("result", "serverInfo", "name")
      assert_equal version.to_s, response.dig("result", "serverInfo", "version")
    ensure
      Process.kill("TERM", io.pid)
    end
  end
end
