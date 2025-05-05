#!/bin/bash
git config --global push.autoSetupRemote true

echo "alias gst='git status'" >> ~/.bashrc
echo "alias ga='git add'" >> ~/.bashrc
source ~/.bashrc
