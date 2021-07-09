set -e

npm run build

cd dist

git init
git add -A
git commit -m 'deploy'
git push -f https://github.com/kb274483/Vue-MiniMusicPlayer.git main:gh-pages

cd -