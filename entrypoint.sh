#!/bin/sh

set -e
set -o pipefail

echo "starting to execute script"

# echo 'value of environment variables' $HUGO_VERSION $PUSH_TOKEN $GITHUB_TOKEN $INPUT_REPO-TOKEN 'delimiter' $GITHUB_WORKSPACE 'delimiter' $TARGET_REPO

# echo 'pwd: ' $pwd

if [[ -z "$PUSH_TOKEN" ]]; then
        echo "using PUSH_TOKEN env variable."
	exit 1
fi

if [[ -z "$TARGET_REPO" ]]; then
	echo "Set the TARGET_REPO env variable."
	exit 1
fi

if [[ -z "$HUGO_VERSION" ]]; then
	HUGO_VERSION=0.59.1
    echo 'No HUGO_VERSION was set, so defaulting to '$HUGO_VERSION
fi

# echo `ls -al $GITHUB_WORKSPACE`

echo 'Downloading hugo'
curl -sSL https://github.com/spf13/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz > /tmp/hugo.tar.gz && tar -f /tmp/hugo.tar.gz -xz

echo 'Download complete'
./hugo

echo 'Cloning the GitHub Pages repo'
BUILD_DIR=build
rm -fr "${BUILD_DIR}"

TARGET_REPO_URL="https://${PUSH_TOKEN}@github.com/${TARGET_REPO}.git"
git clone "${TARGET_REPO_URL}" "${BUILD_DIR}"

# echo `ls -al build`

echo 'Moving the content over'
cp -r public/* build/

echo 'Committing the site to git and pushing'
(
    if git config --get user.name; then
        git config --global user.name "${GITHUB_ACTOR}"
    fi

    if ! git config --get user.email; then
        git config --global user.email "${GITHUB_ACTOR}@users.noreply.github.com"
    fi

    cd "${BUILD_DIR}"

    if git diff --exit-code; then
        echo "There is nothing to commit, so aborting"
        exit 0
    fi

    # Now add all the changes and commit and push
    git remote set-url origin git@gitserver.com:pkanwar23/pkanwar.github.io.git
    git add . && \
    git commit -m "Publishing site $(date)" && \
    git push origin master
)

echo 'Complete'




