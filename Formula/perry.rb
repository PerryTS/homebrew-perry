class Perry < Formula
  desc "Native TypeScript compiler — compiles TypeScript to native executables"
  homepage "https://github.com/PerryTS/perry"
  version "0.2.203"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/PerryTS/perry/releases/download/v0.2.203/perry-macos-aarch64.tar.gz"
      sha256 "8f92d29ca541a6572b425cbc8605a16e194268a6023ec97fe52bcc7f70c8631b"
    else
      url "https://github.com/PerryTS/perry/releases/download/v0.2.203/perry-macos-x86_64.tar.gz"
      sha256 "1dd7d1d3ba26ca0855ccbed9726a3cf3d5c1ebf74af2532648a7eaf8cc71bc5b"
    end
  end

  on_linux do
    url "https://github.com/PerryTS/perry/archive/refs/tags/v0.2.203.tar.gz"
    sha256 "fbf2621482f77edbfe8c30ed5d9e951003b7e27e45ce1bb0e3c3a8bc584c5dbd"
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
