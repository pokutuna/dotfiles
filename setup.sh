#!/bin/sh

HOME_PATH=~
DOTFILES_PATH=`pwd`

if [ -d ${HOME_PATH}/.old_dotfiles ];then
    rm -rf ${HOME_PATH}/.old_dotfiles
fi
mkdir ${HOME_PATH}/.old_dotfiles

## with dot prefix ##
for file in zsh.d zshrc zshenv tmux.conf screenrc gitconfig gitignore gitattributes ackrc gemrc repl proverc vimrc vim tigrc
do
    echo "${file}"
    mv ${HOME_PATH}/.${file} ${HOME_PATH}/.old_dotfiles/.${file}
    ln -s ${DOTFILES_PATH}/${file} ${HOME_PATH}/.${file}
done

if [[ -e ~/Dropbox/config/env_secret ]]; then
    ln -s ~/Dropbox/config/env_secret ~/.zsh.d/env_secret
fi

## without dot prefix ##
for file in bin
do
    echo "${file}"
    mv ${HOME_PATH}/${file} ${HOME_PATH}/.old_dotfiles/${file}
    ln -s ${DOTFILES_PATH}/${file} ${HOME_PATH}/${file}
done

## .config ##
for file in $(ls ${DOTFILES_PATH}/config)
do
    echo "config/${file}"
    mv ${HOME_PATH}/.config/${file} ${HOME_PATH}/.old_dotfiles/config.${file}
    ln -s ${DOTFILES_PATH}/config/${file} ${HOME_PATH}/.config/${file}
done

## .claude ##
mkdir -p ${HOME_PATH}/.claude
for file in $(ls ${DOTFILES_PATH}/claude)
do
    echo "claude/${file}"
    mv ${HOME_PATH}/.claude/${file} ${HOME_PATH}/.old_dotfiles/claude.${file}
    ln -s ${DOTFILES_PATH}/claude/${file} ${HOME_PATH}/.claude/${file}
done

echo ".ssh/config"
mv ${HOME_PATH}/.ssh/config ${HOME_PATH}/.old_dotfiles/ssh-config
ln -s ${DOTFILES_PATH}/ssh-config ${HOME_PATH}/.ssh/config

echo "--- submodule ---"
cd ${DOTFILES_PATH}
git submodule init
git submodule update
git submodule foreach 'git checkout master'
