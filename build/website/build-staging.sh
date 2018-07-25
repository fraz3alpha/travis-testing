#!/usr/bin/env bash

# This script pushing the built copy of the this site to a staging repository

# Enable exit on failure
set -e

echo "Copying shared resources to the website folder"

echo "Copying badges to website img/badges directory"
mkdir -p website/img/badges
cp -r images/badges/256x256/*.png website/img/badges/

echo "Copying flags to website img/flags directory"
mkdir -p website/img/flags
cp -r images/flags/twemoji/png/*.png website/img/flags/

echo "Copying logos to website img/logo directory"
mkdir -p website/img/logo
cp -r images/logo/*.png website/img/logo/

echo "Copying screenshots to website img/screenshots directory"
mkdir -p website/img/screenshots
cp -r images/screenshots/*.png website/img/screenshots/

# based on https://jekyllrb.com/docs/continuous-integration/travis-ci/

# Move into the website directory
cd website

SITE_DIR=_site

# Clear out the build directory
rm -rf ${SITE_DIR} && mkdir ${SITE_DIR}

# Fiddle around with some files so that it works for the staging environment
# Overwrite the CNAME file
echo "staging.running-challenges.co.uk" > CNAME
# Don't set this for now
# rm -f CNAME
# Adjust the url file
sed -i -e 's/https:\/\/www.running-challenges.co.uk/https:\/\/staging.running-challenges.co.uk/' _config.yml
sed -i -e 's/Running Challenges/Running Challenges - Staging/' _config.yml

# Build the site
bundle install
bundle exec jekyll build

# Print summary
echo "Built site, total size: `du -sh ${SITE_DIR}`"

# Initialise the git repo
cd ${SITE_DIR}
# Add a file to say that the site doesn't need building
touch .nojekyll

# Setup git to push to the staging repo
git init
# Add the target remote
git remote add staging https://${GH_PAGES_GITHUB_TOKEN}@github.com/fraz3alpha/travis-testing.git
# Create a new branch, and commit all the code
git checkout -b gh-pages-staging
git add -A
git commit -m 'Travis build for staging'
git log -1
git push --force staging gh-pages-staging
