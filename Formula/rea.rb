class Rea < Formula
  desc "Reverse engineering CLI and MCP server for agents"
  homepage "https://github.com/morluto/rea"
  url "https://registry.npmjs.org/rea-agents/-/rea-agents-6.9.0.tgz"
  sha256 "322338a1505e2557702a16012e7d46abdb5729641d98938662762dfbfb79262a"
  license "MIT"

  depends_on "ghidra"
  depends_on "kurefm/tap/jadx-headless-mcp"
  depends_on "node"
  depends_on "openjdk@25"

  def install
    system "npm", "install", *std_npm_args
    bin.install libexec.glob("bin/*")
    bin.env_script_all_files libexec/"bin", Language::Java.overridable_java_home_env("25").merge(
      GHIDRA_INSTALL_DIR: "${GHIDRA_INSTALL_DIR:-#{formula_opt_libexec("ghidra")}}",
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
