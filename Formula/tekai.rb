class Tekai < Formula
  desc "Self-contained, fidelity-preserving LaTeX engine and build system"
  homepage "https://github.com/NicoNekoru/tekai"
  url "https://github.com/NicoNekoru/tekai/archive/refs/tags/v0.3.0.tar.gz"
  sha256 "aab164f7dc9d8b44b47312ff0d4b3884f992bcb6f7c9a44efa8b83f3f713a232"
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
    (testpath/"main.tex").write <<~'EOS'
      \documentclass{article}
      \usepackage{eso-pic,fancyhdr,times}
      \begin{document}
      {\scshape Conference title}\par
      {\bfseries Anonymous authors}\par
      {\itshape Italic text}
      \end{document}
    EOS
    system bin/"tekai", "build", "main.tex", "--report-json"
    assert_path_exists testpath/"build/main.pdf"
    assert_match "utmb8a.pfb", (testpath/"build/main.log").read.gsub(/\s+/, "")
  end
end
