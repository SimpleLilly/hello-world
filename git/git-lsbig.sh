git verify-pack -v .git/objects/pack/pack-*.idx | sort -r -k 4 -n | head -1000 > git-bigls-list
git rev-list --objects --all > git-bigls-revlist

cat git-bigls-list | awk '{print "echo " $4 " `grep " $1 " git-bigls-revlist`"}' > git-bigls-run

sh git-bigls-run | awk '{print $1 " " $3}'

rm -f git-bigls-run
rm -f git-bigls-list
rm -f git-bigls-revlist

