class Lsdir < Formula
  include Language::Python::Virtualenv

  desc "Enhanced directory listing tool with content preview"
  homepage "https://github.com/sodium-hydroxide/lsdir"
  url "https://github.com/sodium-hydroxide/lsdir/archive/refs/tags/v0.1.3.tar.gz"
  sha256 "dbb6d0ae2df6363ba046077d0c824e120fe78fc45ec7c0a707b8dee5437ac70f"
  license "MIT"

  depends_on "python@3.11"

  resource "python-magic" do
    url "https://files.pythonhosted.org/packages/da/db/0b3e28ac047452d079d375ec6798bf76a036a08182dbb39ed38116a49130/python-magic-0.4.27.tar.gz"
    sha256 "dbb6d0ae2df6363ba046077d0c824e120fe78fc45ec7c0a707b8dee5437ac70f"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    system bin/"lsdir", "--help"
  end
end
