class Lsdir < Formula
  include Language::Python::Virtualenv

  desc "Enhanced directory listing tool with content preview"
  homepage "https://github.com/sodium-hydroxide/lsdir"
  url "https://github.com/sodium-hydroxide/lsdir/archive/refs/tags/v0.1.6.tar.gz"
  sha256 "ed5c7e66a9944f5d9e3cda109f09bb34cedae8571f595d7399fcc5f7f3fdffa1"  # Your package hash
  license "MIT"

  resource "python-magic" do      url "https://files.pythonhosted.org/packages/da/db/0b3e28ac047452d079d375ec6798bf76a036a08182dbb39ed38116a49130/python-magic-0.4.27.tar.gz"
    sha256 "c1ba14b08e4a5f5c31a302b7721239695b2f0f058d125bd5ce1ee36b9d9d3c3b"  # python-magic hash
  end

  depends_on "python@3.11"

  def install
    virtualenv_install_with_resources
  end

  test do
    system bin/"lsdir", "--help"
  end
end
