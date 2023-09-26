# Example lib: react-xarrows. First, fork react-xarrows on github
cd ~/LocalRepo
git clone https://github.com/cywhale/react-xarrows.git
cd react-xarrows
git remote add upstream https://github.com/Eliav2/react-xarrows.git
git fetch upstream pull/175/head:pr-175
git checkout pr-175
git checkout master
git merge pr-175
git push origin master

cd ~/YourApp/client
yarn add https://github.com/cywhale/react-xarrows.git#55c196f

cd ~/LocalRepo/react-xarrows
yarn install
yarn upgrade webpack
yarn add -D typescript
yarn build:prod

cp -R lib ~/YourApp/client/node_modules/react-xarrows/

## modify vite.config.ts
##  optimizeDeps: {
##    include: ['react-xarrows/lib/index.js'],

## modify import react-xarrows
## import Xarrow, { Xwrapper } from 'react-xarrows/lib/index.js'
