class Perry < Formula
  desc "Native TypeScript compiler — compiles TypeScript to native executables"
  homepage "https://github.com/PerryTS/perry"
  version "0.5.18"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/PerryTS/perry/releases/download/v0.5.18/perry-macos-aarch64.tar.gz"
      sha256 "29d688434f73908e24259f1195fa3280f55a3995d05fa33f37bcae99682d12ab"
    else
      url "https://github.com/PerryTS/perry/releases/download/v0.5.18/perry-macos-x86_64.tar.gz"
      sha256 "3002860afff02854dc478a2355730accf79632596027c8bb7e534f668df327b5"
    end
  end

  on_linux do
    url "https://github.com/PerryTS/perry/archive/refs/tags/v0.5.18.tar.gz"
    sha256 "2ecb8283442bd4630e70dd196f0be0d19bb08da74d5adeb923aa65f60ca438f5"
    depends_on "rust" => :build
  end

  def install
    if OS.mac?
      bin.install "perry"
      lib.install Dir["libperry_*.a"]
    else
      system "cargo", "build", "--release"
      system "cargo", "build", "--release", "-p", "perry-runtime", "-p", "perry-stdlib"
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
