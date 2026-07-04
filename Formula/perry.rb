class Perry < Formula
  desc "Native TypeScript compiler — compiles TypeScript to native executables"
  homepage "https://github.com/PerryTS/perry"
  version "0.5.1220"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/PerryTS/perry/releases/download/v0.5.1220/perry-macos-aarch64.tar.gz"
      sha256 "f5d203ab4ed845812cc471213172a3154c76ade2200faf9759d0769678451d86"
    else
      url "https://github.com/PerryTS/perry/releases/download/v0.5.1220/perry-macos-x86_64.tar.gz"
      sha256 "52db5bdaf97b3c6e3d8ffa4c9dd1977c401eeaa9fbd0d7432955583d416bfb06"
    end
  end

  on_linux do
    url "https://github.com/PerryTS/perry/archive/refs/tags/v0.5.1220.tar.gz"
    sha256 "e4bcd0f362e001101a0d1b3683d14bd8e42b882dd59a1395be670fb9af9593c3"
    depends_on "rust" => :build
  end

  def install
    if OS.mac?
      bin.install "perry"
      lib.install Dir["libperry_*.a"]
    else
      system "cargo", "build", "--release"
      system "cargo", "build", "--release", "-p", "perry-runtime", "-p", "perry-stdlib", "-p", "perry-runtime-static", "-p", "perry-stdlib-static"
      bin.install "target/release/perry"
      lib.install Dir["target/release/libperry_*.a"]
    end
  end

  def caveats
    <<~EOS
      Perry requires a C linker to link compiled executables.

      macOS:  Xcode Command Line Tools (xcode-select --install)
      Linux:  GCC or Clang (sudo apt install build-essential)

      Quick start:
        echo 'console.log("hello")' > hello.ts
        perry hello.ts -o hello && ./hello
    EOS
  end

  test do
    assert_match "perry", shell_output("#{bin}/perry --version")
    (testpath/"test.ts").write('console.log("works");')
    system bin/"perry", testpath/"test.ts", "-o", testpath/"test"
    assert_equal "works\n", shell_output(testpath/"test")
  end
end
