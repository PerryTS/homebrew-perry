class Perry < Formula
  desc "Native TypeScript compiler — compiles TypeScript to native executables"
  homepage "https://github.com/PerryTS/perry"
  version "0.4.41"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/PerryTS/perry/releases/download/v0.4.41/perry-macos-aarch64.tar.gz"
      sha256 "eb126234ac6bb234545757fcf4872255bbf26b46b8140d38f9fa5c1a31f0359f"
    else
      url "https://github.com/PerryTS/perry/releases/download/v0.4.41/perry-macos-x86_64.tar.gz"
      sha256 "74685cd5222560aa385b6376718eae6b4a7d12564a0e99fb558fa6ffd88633b9"
    end
  end

  on_linux do
    url "https://github.com/PerryTS/perry/archive/refs/tags/v0.4.41.tar.gz"
    sha256 "12f7f2807f679fbee1370c96565e058078666cd10ddd7b3d96ca3ae66211a933"
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
