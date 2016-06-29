#!/bin/sh

HOME_PATH=~
DOTFILES_PATH=`pwd`

if [ -d ${HOME_PATH}/.old_dotfiles ];then
    rm -rf ${HOME_PATH}/.old_dotfiles
fi
mkdir ${HOME_PATH}/.old_dotfiles

## with dot prefix ##
for file in zsh.d zshrc zshenv tmux.conf screenrc gitconfig gitignore emacs.d ackrc gemrc repl proverc vimrc vim tigrc
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

## .config ##
for file in $(ls ${DOTFILES_PATH}/config)
do
    echo "config/${file}"
    mv ${HOME_PATH}/.config/${file} ${HOME_PATH}/.old_dotfiles/config.${file}
    ln -s ${DOTFILES_PATH}/config/${file} ${HOME_PATH}/.config/${file}
done



echo ".ssh/config"
mv ${HOME_PATH}/.ssh/config ${HOME_PATH}/.old_dotfiles/ssh-config
ln -s ${DOTFILES_PATH}/ssh-config ${HOME_PATH}/.ssh/config


echo "--- .emacs.d/etc/ ---"
mv ${HOME_PATH}/.emacs.d/etc ${HOME_PATH}/.old_dotfiles/etc_emacs
ln -s ${HOME_PATH}/Dropbox/etc_emacs ${HOME_PATH}/.emacs.d/etc
ls -l ${HOME_PATH}/Dropbox/etc_emacs | tee -a etc_emacs


echo "--- submodule ---"
cd ${DOTFILES_PATH}
git submodule init
git submodule update
git submodule foreach 'git checkout master'
