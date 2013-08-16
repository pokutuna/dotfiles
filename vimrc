set nocompatible
set backspace=indent,eol,start

set nobackup
set viminfo=!,'50,<1000,s100,\"50 "
set history=100
set ruler

" 補完時に無視されるファイル名のsuffix
set suffixes=.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc

syntax on

colorscheme default

" 補完候補の色づけ
hi Pmenu ctermfg=Black
hi Pmenu ctermbg=Gray
hi PmenuSel ctermfg=Black
hi PmenuSel ctermbg=Cyan
hi PmenuSbar ctermfg=White
hi PmenuSbar ctermbg=DarkGray

set number

set modelines=1

" タブ幅の設定
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4
set shiftround

"インデントの設定
set autoindent
set smartindent
set cindent

"検索文字列が小文字の場合は大文字小文字を区別なく検索する
set ignorecase

"検索文字列に大文字が含まれている場合は区別して検索する
set smartcase

"検索時に最後まで行ったら最初に戻る
set wrapscan



"検索文字列入力時に順次対象文字列にヒットさせる
set incsearch

"入力中のコマンドをステータスに表示する
set showcmd

"括弧入力時の対応する括弧を表示
set showmatch

"検索結果文字列のハイライトを有効にする
set hlsearch

"ステータスラインを常に表示
set laststatus=2

" コマンドライン補完するときに強化されたものを使う(参照 :help wildmenu)
set wildmenu

" コマンドライン補間をシェルっぽく
set wildmode=list:longest

" バッファが編集中でもその他のファイルを開けるように
set hidden

" 外部のエディタで編集中のファイルが変更されたら自動で読み直す
set autoread

" 文字コードの自動認識
" from ずんWiki http://www.kawaz.jp/pukiwiki/?vim#content_1_7
set encoding=utf-8
set fileencoding=utf-8
if &encoding !=# 'utf-8' " utf-8をデフォルトに
  set encoding=japan
  set fileencoding=japan
endif
if has('iconv')
  let s:enc_euc = 'euc-jp'
  let s:enc_jis = 'iso-2022-jp'
  " iconvがeucJP-msに対応しているかをチェック
  if iconv("¥x87¥x64¥x87¥x6a", 'cp932', 'eucjp-ms') ==# "¥xad¥xc5¥xad¥xcb"
    let s:enc_euc = 'eucjp-ms'
    let s:enc_jis = 'iso-2022-jp-3'
  " iconvがJISX0213に対応しているかをチェック
  elseif iconv("¥x87¥x64¥x87¥x6a", 'cp932', 'euc-jisx0213') ==# "¥xad¥xc5¥xad¥xcb"
    let s:enc_euc = 'euc-jisx0213'
    let s:enc_jis = 'iso-2022-jp-3'
  endif
  " fileencodingsを構築
  if &encoding ==# 'utf-8'
    let s:fileencodings_default = &fileencodings
    let &fileencodings = s:enc_jis .','. s:enc_euc .',cp932'
    let &fileencodings = &fileencodings .','. s:fileencodings_default
    unlet s:fileencodings_default
  else
    let &fileencodings = &fileencodings .','. s:enc_jis
    set fileencodings+=utf-8,ucs-2le,ucs-2
    if &encoding =~# '^¥(euc-jp¥|euc-jisx0213¥|eucjp-ms¥)$'
      set fileencodings+=cp932
      set fileencodings-=euc-jp
      set fileencodings-=euc-jisx0213
      set fileencodings-=eucjp-ms
      let &encoding = s:enc_euc
      let &fileencoding = s:enc_euc
    else
      let &fileencodings = &fileencodings .','. s:enc_euc
    endif
  endif
  let &fileencodings = 'utf-8' . ',' . &fileencodings " XXX: adhocな対応
  " 定数を処分
  unlet s:enc_euc
  unlet s:enc_jis
endif

" 日本語を含まない場合は fileencoding に encoding を使うようにする
if has('autocmd')
  function! AU_ReCheck_FENC()
    if &fileencoding =~# 'iso-2022-jp' && search("[^¥x01-¥x7e]", 'n') == 0
      let &fileencoding=&encoding
    endif
  endfunction
  autocmd BufReadPost * call AU_ReCheck_FENC()
endif

" 改行コードの自動認識
set fileformats=unix,dos,mac

" □とか○の文字があってもカーソル位置がずれないようにする
set ambiwidth=double

" 辞書ファイルからの単語補間
set complete+=k

nnoremap j gj
nnoremap k gk
vnoremap j gj
vnoremap k gk


" for vundle"
set rtp+=~/.vim/co/vundle/
call vundle#rc('~/.vim/bundle')

Bundle 'Shougo/neocomplcache'
