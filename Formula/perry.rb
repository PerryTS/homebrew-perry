class Perry < Formula
  desc "Native TypeScript compiler — compiles TypeScript to native executables"
  homepage "https://github.com/PerryTS/perry"
  version "0.2.179"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/PerryTS/perry/releases/download/v0.2.179/perry-macos-aarch64.tar.gz"
      sha256 "e2f104637ae1a9d4bbed6a6409cfa334ca2dadd9291f749431a65e3ae1a47054"
    else
      url "https://github.com/PerryTS/perry/releases/download/v0.2.179/perry-macos-x86_64.tar.gz"
      sha256 "cb56fbda37814bea5fff01de9827687cdb367701979fae8556ffc985511a3f9b"
    end
  end

  on_linux do
    url "https://github.com/PerryTS/perry/archive/refs/tags/v0.2.179.tar.gz"
    sha256 "9a4a510ad44e91656bc55c18c752499180a08eb1fc45261933ff2c2bd4397f24"
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
