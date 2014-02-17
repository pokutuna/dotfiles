#! /usr/bin/env ruby
# -*- coding: utf-8 -*-

# MAX = 30

# current_branch = `git rev-parse --abbrev-ref HEAD`

# revs = `git rev-list --max-count=#{MAX} HEAD`.split("\n")

# descendants_pattern = `git branch --contains HEAD | sed 's/^[* ] //'`.split("\n").join('|')

# branches = nil
# revs.shift # 先頭は親ブランチなはずは無いので捨てる
# revs.each do |rev|
#   branches = `git branch --contains #{rev} | grep -vE '#{descendants_pattern}'`.split("\n").map(&:strip)

#   p branches.map{ |b|
#     `git merge-base --is-ancestor #{b} HEAD`
#     [b, $?.success?]
#   }

#   branches = branches.map{ |b|
#     remote_name = `git rev-parse --abbrev-ref #{b}@{upstream} 2>&1`
#     $?.success? ? remote_name.chomp : nil
#   }.compact
#   break if branches.length != 0
# end

# exit if branches.length.zero?

# # 親っぽいのが1つならそれ、複数あったら一番短いやつ
# parent = branches.length == 1 ? branches.first : branches.sort_by(&:length).first

# puts "git diff #{parent}...origin/#{current_branch}"


# ### この branch がどこから切られたか heuristics に見つける
# current_branch = `git rev-parse --abbrev-ref HEAD`
# # このブランチにしか含まれない commit の最初の sha1 を得る
# current_branch_first_commit = `git rev-list --all --not $(git rev-list --all ^#{current_branch}) | tail -n 1`.chomp

# # if current_branch_first_commit.empty?

# # 大抵 local branch から切るはずだし -r は遅くなるからつけないでおく
# candidate_branches =
#   `git branch --contains $(git rev-parse #{current_branch_first_commit}^) | sed 's/^[* ] //'`.split("\n")

# # remote に名前があって一番短い名前の branch 名を探す
# remote_name = nil
# candidate_branches.sort_by{ |name| name.length }.each{ |br|
#   remote_name = `git rev-parse --abbrev-ref #{br}@{upstream} 2>/dev/null`.chomp
#   break if $?.success?
# }

PREFIX = '[diff-command]'

### この branch がどこから切られたか heuristics に見つける
current_branch = `git rev-parse --abbrev-ref HEAD`.chomp
# reflog から探す、レビュー依頼するのは自分で切った branch のはずなので見つかると思うな〜
created_commit = `git reflog #{current_branch} | grep Created | tail -n 1 | cut -d' ' -f1`.chomp

unless created_commit.empty?
  # 大抵 local branch から切るはずだし -r は遅くなるのでつけないでおくね
  candidate_branches =
    `git branch --contains #{created_commit} | sed 's/^[* ] //' | grep -vE '^#{current_branch}$'`.split("\n")

  # remote に名前があって一番短い名前の branch 名を探すよ
  remote_name = ''
  candidate_branches.sort_by{ |name| name.length }.each{ |br|
    p br
    remote_name = `git rev-parse --abbrev-ref #{br}@{upstream} 2>/dev/null`.chomp
    break if $?.success?
  }

  puts "#{PREFIX} git diff #{remote_name}...origin/#{current_branch}" unless remote_name.empty?
end
