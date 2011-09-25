#!/bin/sh

HOME_PATH=~
DOTFILES_PATH=`pwd`

if [ -d ${HOME_PATH}/.old_dotfiles ];then
    rm -rf ${HOME_PATH}/.old_dotfiles
fi
mkdir ${HOME_PATH}/.old_dotfiles

## with dot prefix ##
for file in zsh.d zshrc zshenv tmux.conf screenrc gitconfig gitignore emacs.d
do
    echo "${file}"
    mv ${HOME_PATH}/.${file} ${HOME_PATH}/.old_dotfiles/.${file}
    ln -s ${DOTFILES_PATH}/${file} ${HOME_PATH}/.${file}
done


## without dot prefix ##
for file in bin
do
    echo "${file}"
    mv ${HOME_PATH}/${file} ${HOME_PATH}/.old_dotfiles/${file}
    ln -s ${DOTFILES_PATH}/${file} ${HOME_PATH}/${file}
done


## with specific path  ##
echo "ssh"
mv ${HOME_PATH}/.ssh/config ${HOME_PATH}/.old_dotfiles/ssh-config
ln -s ${DOTFILES_PATH}/ssh-config ${HOME_PATH}/.ssh/config
