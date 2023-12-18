from pythonforandroid.recipe import CythonRecipe
from pythonforandroid.toolchain import shutil
from os.path import join


class BlsPyRecipe(CythonRecipe):

    url = ('https://files.pythonhosted.org/packages/26/9b/'
           'bede04d51147bc12021cfb2c1f39289bb8856dbb53af143dfef22ffe2eb6/'
           'python-bls-0.1.10.tar.gz')
    sha256sum = 'e43854a151606891794631e8c805a8b23b087666754c8bdaeeb687ed97961754'
    version = '0.1.10'
    depends = ['python3', 'setuptools', 'libgmp']

    def build_arch(self, arch):
        # copy gmp.h from libgmp/dist/include to extmod/bls_py
        self_build_dir = self.get_build_dir(arch.arch)
        libgmp_build_dir = self_build_dir.replace('bls_py', 'libgmp')
        libgmp_build_dir = libgmp_build_dir.replace('-python3', '')
        local_path = join(self_build_dir, 'extmod', 'bls_py', 'gmp.h')
        libgmp_path = join(libgmp_build_dir, 'dist', 'include', 'gmp.h')
        shutil.copyfile(libgmp_path, local_path)
        super(BlsPyRecipe, self).build_arch(arch)


recipe = BlsPyRecipe()
