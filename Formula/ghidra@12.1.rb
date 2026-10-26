class GhidraAT121 < Formula
  desc "Multi-platform software reverse engineering framework"
  homepage "https://github.com/NationalSecurityAgency/ghidra"
  url "https://github.com/NationalSecurityAgency/ghidra/archive/refs/tags/Ghidra_12.1.4_build.tar.gz"
  sha256 "2a858300c350f05ae2e729dff86b4f584d0b9a6b398879c55025574e67696cec"
  license "Apache-2.0"

  livecheck do
    url :stable
    regex(/^Ghidra[._-]v?(12\.1\.\d+)(?:[._-]build)?$/i)
  end

  keg_only :versioned_formula

  depends_on "gradle" => :build
  depends_on "python@3.14" => :build
  depends_on "openjdk@21"

  def install
    ENV["JAVA_HOME"] = Language::Java.java_home("21")
    inreplace "Ghidra/application.properties", "DEV", "PUBLIC"
    system "gradle", "-I", "gradle/support/fetchDependencies.gradle"
    system "gradle", "buildNatives"
    system "gradle", "assembleAll", "-x", "FileFormats:extractSevenZipNativeLibs"

    libexec.install (buildpath/"build/dist/ghidra_#{version}_PUBLIC").children
    (bin/"ghidraRun").write_env_script libexec/"ghidraRun",
                                       Language::Java.overridable_java_home_env("21")
    (bin/"pyghidraRun").write_env_script libexec/"support/pyghidraRun",
                                         Language::Java.overridable_java_home_env("21")

    os = OS.mac? ? "mac" : "linux"
    arch = Hardware::CPU.arm? ? "arm_64" : "x86_64"
    (libexec/"GPL/DemanglerGnu/os").children
                                   .each { |dir| rm_r(dir) if dir.basename.to_s != "#{os}_#{arch}" }
    (libexec/"Ghidra/Features").glob("{Decompiler,FileFormats}/os/*")
                               .each { |dir| rm_r(dir) if dir.basename.to_s != "#{os}_#{arch}" }
  end

  test do
    assert_match "application.version=#{version}", (libexec/"Ghidra/application.properties").read
    os = OS.mac? ? "mac" : "linux"
    arch = Hardware::CPU.arm? ? "arm_64" : "x86_64"
    assert_predicate libexec/"Ghidra/Features/Decompiler/os/#{os}_#{arch}/decompile", :executable?
    assert_match "foo()",
                 shell_output("#{libexec}/GPL/DemanglerGnu/os/#{os}_#{arch}/demangler_gnu_v2_24 _Z3foov")
    (testpath/"analyzeHeadless").write_env_script libexec/"support/analyzeHeadless",
                                                  Language::Java.overridable_java_home_env("21")
    (testpath/"project").mkpath
    system "/bin/bash", testpath/"analyzeHeadless", testpath/"project",
                        "HomebrewTest", "-import", "/bin/bash", "-noanalysis"
    assert_path_exists testpath/"project/HomebrewTest.rep"
  end
end
