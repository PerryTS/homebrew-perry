class Perry < Formula
  desc "Native TypeScript compiler — compiles TypeScript to native executables"
  homepage "https://github.com/PerryTS/perry"
  version "0.4.23"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/PerryTS/perry/releases/download/v0.4.23/perry-macos-aarch64.tar.gz"
      sha256 "317d67c07833459aca02e5bdd6d756d465ea9d63db74024c262fce7d4f0a51f3"
    else
      url "https://github.com/PerryTS/perry/releases/download/v0.4.23/perry-macos-x86_64.tar.gz"
      sha256 "cc7ddf2ef7f1d5f60cdd5d9ac1f5fecbdeba2fa412b46c902a137070acb4e7d9"
    end
  end

  on_linux do
    url "https://github.com/PerryTS/perry/archive/refs/tags/v0.4.23.tar.gz"
    sha256 "d58e3d67e2406cc5fd33c7fe9b421056da3759ed65b1fc1f9170812f6175cb8f"
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
