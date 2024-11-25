class Lsdir < Formula
  include Language::Python::Virtualenv

  desc "Enhanced directory listing tool with content preview"
  homepage "https://github.com/sodium-hydroxide/lsdir"
  url "https://github.com/sodium-hydroxide/lsdir/archive/refs/tags/v0.1.3.tar.gz"
  sha256 "4dad148cbb19c6aad72773d1b4fbbfbdd3958b9ba10efda41aa26e99926f3d4c"
  license "MIT"

  depends_on "python@3.11"

  resource "python-magic" do
    url "https://files.pythonhosted.org/packages/da/db/0b3e28ac047452d079d375ec6798bf76a036a08182dbb39ed38116a49130/python-magic-0.4.27.tar.gz"
    sha256 "4dad148cbb19c6aad72773d1b4fbbfbdd3958b9ba10efda41aa26e99926f3d4c"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    system bin/"lsdir", "--help"
  end
end
