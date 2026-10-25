class Rea < Formula
  desc "Reverse engineering CLI and MCP server for agents"
  homepage "https://github.com/morluto/rea"
  url "https://registry.npmjs.org/rea-agents/-/rea-agents-6.8.0.tgz"
  sha256 "8d542ec76a9cb350584b60a6c9c088706ff812d5bb5b094c20c95b6dc25698bb"
  license "MIT"

  depends_on "kurefm/tap/ghidra@12.1"
  depends_on "kurefm/tap/jadx-headless-mcp"
  depends_on "node"
  depends_on "openjdk@21"

  def install
    system "npm", "install", *std_npm_args
    bin.install libexec.glob("bin/*")
    bin.env_script_all_files libexec/"bin", Language::Java.overridable_java_home_env("21").merge(
      GHIDRA_INSTALL_DIR: "${GHIDRA_INSTALL_DIR:-#{formula_opt_libexec("kurefm/tap/ghidra@12.1")}}",
      REA_JADX_MCP_JAR:   "${REA_JADX_MCP_JAR:-" \
                          "#{formula_opt_libexec("kurefm/tap/jadx-headless-mcp")}/jadx-headless-mcp.jar}",
    )
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/rea --version")

    (testpath/"app/package.json").write('{"name":"rea-test","version":"1.0.0","main":"index.js"}')
    (testpath/"app/index.js").write("module.exports = function greet() { return 'hello'; };\n")
    output = shell_output("#{bin}/rea analyze-javascript-application #{testpath}/app --json")
    assert_match "greet", output
  end
end
