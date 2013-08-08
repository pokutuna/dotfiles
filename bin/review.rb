#! /usr/bin/env ruby
# -*- coding: utf-8 -*-

MAX = 20
NG_WORD = /fix|feature|(?<!origin)\//

current_branch = `git rev-parse --abbrev-ref HEAD`

revs = `git rev-list --max-count=#{MAX} HEAD`.split("\n")

branches = nil
revs.each do |rev|
  branches = `git branch -r --contains #{rev} | grep -v #{current_branch}`.split("\n").map(&:strip)
  branches.delete_if{ |b| b =~ NG_WORD }
  break if branches.length != 0
end

exit if branches.length.zero?

# 親っぽいのが1つならそれ、複数あったら一番短いやつ
parent = branches.length == 1 ? branches.first : branches.sort_by(&:length).first

puts "git diff #{parent}...origin/#{current_branch}"
