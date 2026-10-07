class Tekai < Formula
  desc "Self-contained, fidelity-preserving LaTeX engine and build system"
  homepage "https://github.com/NicoNekoru/tekai"
  url "https://github.com/NicoNekoru/tekai/archive/refs/tags/v0.5.0.tar.gz"
  sha256 "b6d0866d665e4abe0b867f7cdf229b7495e273638c5d3ad1489230d19079ce26"
  license "MIT"
  head "https://github.com/NicoNekoru/tekai.git", branch: "main"

  depends_on "rust" => :build
  depends_on :macos

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match "tekai #{version}", shell_output("#{bin}/tekai --version")
    assert_match "self-contained engine", shell_output("#{bin}/tekai --help")

    ENV["TEKAI_ENGINE_CACHE"] = testpath/"cache"
    ENV["PATH"] = ""
    ENV["TEXMFHOME"] = testpath/"texmf"
    (testpath/"texmf/tex/latex/tekaitest/sharedprobe.sty").write <<~'EOS'
      \ProvidesPackage{sharedprobe}
      \typeout{SHARED-PACKAGE-LOADED}
    EOS
    mkdir "paper" do
      assert_match(/"source":\s*"TEXMFHOME"/,
                   shell_output("#{bin}/tekai locate sharedprobe.sty --report-json"))
      ENV["TEKAI_TEXMF_MODE"] = "bundled"
      assert_match(/"path":\s*null/,
                   shell_output("#{bin}/tekai locate sharedprobe.sty --report-json", 1))
      ENV["TEKAI_TEXMF_MODE"] = "shared"
      (testpath/"paper/format.tex").write "Inline $x$.\n"
      assert_match(/"fixes_available":\s*2/,
                   shell_output("#{bin}/tekai format format.tex --check --report-json", 1))
      assert_equal "Inline $x$.\n", (testpath/"paper/format.tex").read
      system bin/"tekai", "format", "format.tex", "--report-json"
      assert_equal "Inline \\(x\\).\n", (testpath/"paper/format.tex").read
      system bin/"tekai", "format", "format.tex", "--check", "--report-json"

      (testpath/"paper/main.tex").write <<~'EOS'
        \documentclass{article}
        \usepackage{sharedprobe,eso-pic,fancyhdr,times}
        \begin{document}
        {\scshape Conference title}\par
        {\bfseries Anonymous authors}\par
        {\itshape Italic text}
        \end{document}
      EOS
      system bin/"tekai", "build", "main.tex", "--report-json"
      assert_path_exists testpath/"paper/build/main.pdf"
      assert_match "SHARED-PACKAGE-LOADED", (testpath/"paper/build/main.log").read
      assert_match "utmb8a.pfb", (testpath/"paper/build/main.log").read.gsub(/\s+/, "")
    end
  end
end
