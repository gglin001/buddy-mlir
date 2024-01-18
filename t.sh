git submodule init
git submodule update --recursive --init --depth=1 thirdparty/mimalloc

# optional: softlink llvm-project

git submodule update --recursive --init --depth=1

# -----

# clone once
pushd ..
git clone https://github.com/llvm/llvm-project.git
popd

TAG="6c59f0e1b0fb56c909ad7c9aad4bde37dc006ae0"
mkdir llvm-project-$TAG
pushd llvm-project-$TAG
git init
git remote add origin ../../llvm-project
git fetch --depth 1 origin $TAG
git checkout FETCH_HEAD
git remote set-url origin https://github.com/llvm/llvm-project.git
popd

# replace with local repo
rm -rf $PWD/llvm
ln -sf $PWD/llvm-project-$TAG $PWD/llvm

# build llvm
cmake \
    -DCMAKE_BUILD_TYPE:STRING=Release \
    -DLLVM_ENABLE_PROJECTS="mlir;clang" \
    -DLLVM_TARGETS_TO_BUILD="host;RISCV" \
    -DLLVM_ENABLE_ASSERTIONS=ON \
    -DLLVM_ENABLE_LLD=ON \
    -DLLVM_ENABLE_ZSTD=OFF \
    -DLLVM_ENABLE_TERMINFO=OFF \
    -DCMAKE_C_COMPILER_LAUNCHER:STRING=ccache \
    -DCMAKE_CXX_COMPILER_LAUNCHER:STRING=ccache \
    -DCMAKE_EXPORT_COMPILE_COMMANDS:BOOL=TRUE \
    -DCMAKE_INSTALL_PREFIX:STRING=$PWD/build_llvm/install \
    -S $PWD/llvm/llvm \
    -B $PWD/build_llvm \
    -G Ninja

cmake --build $PWD/build_llvm --target all --

# build buddy-mlir

# test
buddy-opt \
    -lower-rvv \
    examples/RVVDialect/rvv-setvl.mlir
