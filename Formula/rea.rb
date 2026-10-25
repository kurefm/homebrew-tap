class Rea < Formula
  desc "Reverse engineering CLI and MCP server for agents"
  homepage "https://github.com/morluto/rea"
  url "https://registry.npmjs.org/rea-agents/-/rea-agents-6.7.0.tgz"
  sha256 "20958a66dba1a011e50a486beb9463a343128ed368c984f94065362c13f51f90"
  license "MIT"

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink libexec.glob("bin/*")
  end

  def caveats
    <<~EOS
      For Android APK analysis, install the recommended backend:
        brew install kurefm/tap/jadx-headless-mcp
      Then configure the JAR path and a full JDK 17+:
        export REA_JADX_MCP_JAR="#{HOMEBREW_PREFIX}/opt/jadx-headless-mcp/libexec/jadx-headless-mcp.jar"
        export PATH="#{HOMEBREW_PREFIX}/opt/openjdk/bin:$PATH"
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/rea --version")

    (testpath/"app/package.json").write('{"name":"rea-test","version":"1.0.0","main":"index.js"}')
    (testpath/"app/index.js").write("module.exports = function greet() { return 'hello'; };\n")
    output = shell_output("#{bin}/rea analyze-javascript-application #{testpath}/app --json")
    assert_match "greet", output
  end
end
