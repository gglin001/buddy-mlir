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
