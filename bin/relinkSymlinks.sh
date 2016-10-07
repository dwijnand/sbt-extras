# Sometime there are symbolic links stored in git repository
# In order to use them in windows like systems we need to link them using cygwin goodies.
# This procedure will do that.


repoDir=$1
[[ "$repoDir" == "" ]] && repoDir="."

pushd $repoDir > /dev/null

for symlink in $(git ls-files -s | egrep "^120000" | cut -f2); do
    git checkout $symlink #thanks to that it's idempotent
    src=$(cat $symlink)
    dst=$symlink
    rm $dst
    ln -s $src $dst
    echo "$src <<===>> $dst"
done

popd > /dev/null
