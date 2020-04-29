# git submodule 
# refer to https://github.blog/2016-02-01-working-with-submodules/ 
git clone --recursive --progress -- https://github.com/cywhale/openocean.git D:\Gits\openocean
# D:\Gits\openocean
git submodule add https://github.com/jdomingu/ThreeGeoJSON ThreeGeoJSON
git commit -m "ThreeGeoJSON submodule"
git submodule update --init --recursive
git push origin master:master --progress
# git fetch --progress --prune origin

# Similar to git a local folder to a repo subdirectory after git clone 
# But must put your local folder (copy/move) under the directory where you git clone
# cd git_clone_dir/your_local_folder
git add . # after that can use git add -A
git commit -m "git a local folder to a repo subdir"
git push origin master

# A withdraw from git commit should be careful by using git reset HEAD^, that delete your local file if you commit local edit
# Recover it:
git reflog # to see which commit you want to recover
## 42a259f HEAD@{2}: reset: moving to HEAD^
## 6829620 HEAD@{3}: commit: new commit
git reset --hard 682920 ## save local edit by --hard
