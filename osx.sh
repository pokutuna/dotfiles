# show dotfiles in Finder
defaults write com.apple.finder AppleShowAllFiles -boolean true

# KeyRepeat
# 1 = 15ms
defaults write -g InitialKeyRepeat -int 8
defaults write -g KeyRepeat -int 2

# Destroy .localized
find / -maxdepth 2 -name '.localized' | xargs sudo rm
find $HOME -maxdepth 2 -name '.localized' | xargs rm
