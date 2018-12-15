target=$1
if [ -z $1 ]; then
	target=cmake
fi
pushd ../../src/config
if [ -f ./bitcoin-config.h ] && [ ! -L ./bitcoin-config.h ]; then
	echo "bitcoin-config.h found and not a symlink"
	mv -v bitcoin-config.h bitcoin-config.gcc.h
fi
if [ -f ./bitcoin-config.$target.h ]; then
	echo "bitcoin-config.$target.h found"
	ln -vfs bitcoin-config.$target.h bitcoin-config.h
fi	
popd
