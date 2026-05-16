class Perry < Formula
  desc "Native TypeScript compiler — compiles TypeScript to native executables"
  homepage "https://github.com/PerryTS/perry"
  version "0.5.923"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/PerryTS/perry/releases/download/v0.5.923/perry-macos-aarch64.tar.gz"
      sha256 "7aa32ff42962988301f51042b73242da74e8c8acde1a274544859e0014d58924"
    else
      url "https://github.com/PerryTS/perry/releases/download/v0.5.923/perry-macos-x86_64.tar.gz"
      sha256 "72f0ad4fbbcb82a782e82f5135c34ef7579624a142e6a83b3015858a90326265"
    end
  end

  on_linux do
    url "https://github.com/PerryTS/perry/archive/refs/tags/v0.5.923.tar.gz"
    sha256 "28e45a9efbe0915bf8012343a7c61e3f70e4f404b045432324a3532002650f75"
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
