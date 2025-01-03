set nocompatible
filetype off                   " required!
set encoding=utf-8

"set rtp+=~/.vim/bundle/Vundle.vim/
"call vundle#begin()
call plug#begin()

" let Vundle manage Vundle, required
"Plug 'gmarik/Vundle.vim'

" github repos
Plug 'tpope/vim-sensible'
"Plug 'tpope/vim-unimpaired'
" TODO: install ycm-compatible Vim
"if v:version >= 704
"  Plug 'Valloric/YouCompleteMe'
"endif
"Plug 'Lokaltog/vim-easymotion'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'wincent/command-t'
"Plug 'fs111/pydoc.vim'
Plug 'mpercy/a.vim'
Plug 'scrooloose/nerdtree'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-obsession'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'mpercy/ack.vim'
"Plug 'airblade/vim-gitgutter'
Plug 'christoomey/vim-tmux-navigator'
Plug 'tmux-plugins/vim-tmux-focus-events'
Plug 'ntpeters/vim-better-whitespace'
"Plug 'fholgado/minibufexpl.vim'   " resets split sizes wtf

Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'
Plug 'vim-scripts/mayansmoke'
Plug 'NLKNguyen/papercolor-theme'
Plug 'derekwyatt/vim-scala'

" color schemes
" a bunch of colorschemes + a gui menu listing them
"Plug 'guns/xterm-color-table.vim'
"Plug 'flazz/vim-colorschemes'
"Plug 'wesgibbs/vim-irblack'
"Plug 'altercation/vim-colors-solarized' " looks terrible on console
"Plug 'desert-warm-256'
"Plug 'morhetz/gruvbox' " looks terrible on console
Plug 'mpercy/wombat256cpp2.vim'

" go-lang support
"Plug 'nsf/gocode', {'rtp': 'vim/'}
"Plug 'fatih/vim-go'

" asciidoc syntax support
Plug 'asciidoc/vim-asciidoc'

" menu maker thing should go last
"Bundle 'ColorSchemeMenuMaker'

" All of your Plugins must be added before the following line
call plug#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
"     :PlugInstall to install plugins
"     :PlugUpdate  to update plugins
"     :PlugDiff    to review the changes from the last update
"     :PlugClean   to remove plugins no longer in the list
"
" For more information, see https://github.com/junegunn/vim-plug
" Put your non-Plugin stuff after this line

" Run powerline
if has('python3')
  set rtp+=~/.local/lib/python3.6/site-packages/powerline/bindings/vim
  python3 from powerline.vim import setup as powerline_setup
  python3 powerline_setup()
  python3 del powerline_setup
endif
" Always show statusline
set laststatus=2
" Use 256 colours (Use this setting only if your terminal supports 256 colours)
set t_Co=256

" from https://github.com/tpope/vim-markdown
autocmd BufNewFile,BufReadPost *.md set filetype=markdown

" vim-markdown
let g:vim_markdown_folding_disabled = 1
let g:vim_markdown_fenced_languages = ['html', 'python', 'bash=sh', 'java', '\c++']
let g:vim_markdown_new_list_item_indent = 2

if has('persistent_undo')
  set undofile
  set undodir=/home/mpercy/.vim/undo
endif

" CTRL-click should open links in my browser, not give me tag errors. Squelch.
" NB: Have to use CTRL+] to follow Vim help links now, though.
map <C-LeftMouse> <LeftMouse>

" Because <Esc> and <C-]> are hard to touch type.
inoremap jk <esc>
cnoremap jk <C-c><esc>
" Train self not to use esc
"Untrain... hard to switch back and forth now when using e.g. IntelliJ
"inoremap <esc> ~

" Need a better shortcut for :A
noremap <silent> <C-a> :call AlternateFile("n")<CR>

syntax on
set hidden
set nu ruler ai ts=8 sts=2 sw=2 sr expandtab
set mouse=a
set ttymouse=xterm2
" ttymouse=sgr fixes annoying 220-col limitation in terminals:
if v:version >= 704
  set ttymouse=sgr
endif
set hlsearch incsearch
set splitright
set lazyredraw " avoid redraw lag when scrolling through large files
set viminfo='30,\"100,:20,%,n~/.viminfo

" cw, dw, *, etc should not include '.' or ':' in a word (super annoying)
set iskeyword+=^,,^-,^.,^:

" No double spacing after periods when joining lines or reformatting.
set nojoinspaces

" Yank to MacOS or X-windows keyboard in Vim 7.3.74 and above.
if system('uname -s') == "Darwin\n"
  set clipboard=unnamed " OSX
else
  set clipboard=unnamedplus " Linux
endif

" Don't clear the clipboard on exit. See http://stackoverflow.com/questions/6453595
autocmd VimLeave * call system('xsel -ib', getreg('+'))

" Great sudo trick from http://nvie.com/posts/how-i-boosted-my-vim/
" This causes a delay after typing 'w' in command mode. Screw that.
"cmap w!! w !sudo tee % >/dev/null

"colors desert-warm-256
"colors grb256

"set background=light
set background=dark
"colors PaperColor
colors wombat256cpp2

set cursorline

let mapleader=","

nmap <silent> <Leader>/ :nohlsearch<CR>
set pastetoggle=<F2>

" switch between buffers with ctrl-e
"this mapping sucks, it disables scrolling down
":nmap <C-e> :e#<CR>

" save / load Vim sessions
"map <F3> :source Session.vim <cr>     " And load session with F3
map <F4> :mksession!<CR> " Quick write session with F4

" NERDTree
nmap <F5> <ESC>:NERDTreeToggle<CR>

" new tab
"map <F6> :tabedit <cr>

" for YCM
nnoremap <leader>jd :YcmCompleter GoTo<CR>
nnoremap <leader>ji :YcmCompleter GoToImprecise<CR>
nnoremap <leader>jh :YcmCompleter GoToInclude<CR>
nnoremap <leader>yf :YcmCompleter FixIt<CR>
nnoremap <leader>yd :YcmCompleter GetDoc<CR>
nnoremap <leader>yp :YcmCompleter GetParent<CR>
nnoremap <leader>yt :YcmCompleter GetType<CR>
nnoremap <leader>ye :YcmDiags<CR>
nnoremap <leader>yy :YcmShowDetailedDiagnostic<CR>

" For C++: don't do extreme indent after block inside switch statement.
" Also use 1 space indent on and 1 additional following public:, private:, etc.
set cinoptions=l1,g2,h1

" Window resizing shortcuts (mnemonic: horizontal, vertical split resizing).
nnoremap <Leader>h- :resize -20<CR>
nnoremap <Leader>h+ :resize +20<CR>
nnoremap <Leader>h= :resize +20<CR>
nnoremap <Leader>v- :vertical resize -20<CR>
nnoremap <Leader>v+ :vertical resize +20<CR>
nnoremap <Leader>v= :vertical resize +20<CR>

" Avoid awkward <C-w> keystroke (mnemonic: window).
nnoremap <Leader>w= <C-w>=<CR>
nnoremap <Leader>w_ <C-w>_<CR>
nnoremap <Leader>w\| <C-w>\|<CR>

"""""""""""""""""""""""""""""""""""""""""""
"" From http://stackoverflow.com/questions/327411/how-do-you-prefer-to-switch-between-buffers-in-vim
""""""""""""""""""""""""""""""""""""
"" Tab triggers buffer-name auto-completion
set wildchar=<Tab> wildmenu wildmode=full
"nmap <Leader>t :CommandT<Return> " this is the default
nmap <Leader>a :bprev<Return>
nmap <Leader>s :bnext<Return>
"map <Leader>d :bd<Return>
nmap <leader>d :bprevious<CR>:bdelete #<CR>
nmap <Leader>f :b

" Show the buffer number in the status line.
"set laststatus=2 statusline=%02n:%<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P
"set laststatus=2 statusline=%02n:%<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P\ %#warningmsg#%{SyntasticStatuslineFlag()}%*

" ctrl- mappings for window navigation
" These are not needed with Chris Toomey's tmux navigator plugin
"map <C-k> <C-w><Up>
"map <C-j> <C-w><Down>
"map <C-l> <C-w><Right>
"map <C-h> <C-w><Left>
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" From http://statico.github.io/vim.html
:nmap ; :CtrlPBuffer<CR>
:let g:ctrlp_map = '<Leader>p'
:let g:ctrlp_match_window_bottom = 1
:let g:ctrlp_match_window_reversed = 1
:let g:ctrlp_custom_ignore = '\v\~$|\.(o|swp|pyc|wav|mp3|ogg|blend)$|(^|[/\\])\.(hg|git|bzr)($|[/\\])|__init__\.py'
:let g:ctrlp_working_path_mode = 0
:let g:ctrlp_dotfiles = 0
:let g:ctrlp_switch_buffer = 0

set wildignore+=*.o,*.class

" CommandT
let g:CommandTRefreshMap = '<C-t>'
let g:CommandTMatchWindowAtTop = 1
let g:CommandTMaxFiles = 50000
let g:CommandTMaxCachedDirectories = 10000
let g:CommandTFileScanner = 'git'
let g:CommandTWildIgnore=&wildignore . ",build/**,thirdparty/src/**,thirdparty/build/**,logs/**,**/target/**,**/CMakeFiles/**"

" airline
"let g:airline#extensions#tabline#enabled = 1
"let g:airline_powerline_fonts = 1
"let g:airline_section_y = 'BN: %{bufnr("%")}'

" hard to tell which buffer is selected
"let g:airline#extensions#bufferline#overwrite_variables = 0
" TODO airline line number is pretty useless with set nu enabled

"au FileType c setl sw=4 sts=4 ts=8 expandtab cindent
"au FileType h setl sw=4 sts=4 ts=8 expandtab cindent
"au FileType hpp setl sw=4 sts=4 ts=8 expandtab cindent
"au FileType cpp setl sw=4 sts=4 ts=8 expandtab cindent
au FileType python setl sw=4 sts=4 ts=8 expandtab cindent

if has("autocmd")
  aug vimrc
  au!
  " restore cursor position when the file has been read
  au BufReadPost *
  \ if line("'\"") > 0 && line("'\"") <= line("$") |
  \   exe "norm g`\"" |
  \ endif
  aug ENG
endif

filetype plugin on

" YouCompleteMe whitelist to disable prompting to read the config file on every
" startup.
let g:ycm_extra_conf_globlist = ['~/class/*',
                                \'~/Documents/Personal/Stanford/*',
                                \'~/src/breakpad/*',
                                \'~/src/glibc/*',
                                \'~/src/glog/*',
                                \'~/src/kudu/*',
                                \'~/src/kudu-c++11/*',
                                \'~/src/kudu-reviews/*',
                                \'~/src/HdrHistogramCpp/*',
                                \'~/src/folly/*',
                                \'~/src/impala/*',
                                \'~/src/eglibc-2.17/*',
                                \'~/src/binutils-2.23.52.20130913/*',
                                \'~/src/httpd/*',
                                \'~/src/mod_mbox/*',
                                \'~/src/mysql-server/*',
                                \'~/src/test/c++/*',
                                \'~/src/pstack/*',
                                \'~/src/binutils-gdb/*',
                                \'~/src/offmarket/*',
                                \'~/src/navencrypt/*',
                                \'~/src/gg_kudu_user_exit/*']
" YCM errors to jump thru with :lnext and :lprevious
let g:ycm_always_populate_location_list = 1

" ctags
"set tags=./tags;/home/mpercy/src

" Kudu-specific ack-grep stuff.
" Use ag instead of ack
let g:ackprg = 'ag -t --depth 100 --nogroup --nocolor --column'
"let g:ackpreview = 1
" Search for current word in all src/ files using <leader>ka
:nnoremap <leader>as :Ack! '\b<cword>\b' src/kudu/<CR>
:nnoremap <leader>ag :Ack! '\b<cword>\b'<CR>

" Regex to replace HTML links with markdown links in the current document.
function HtmlLinksToMarkdown()
  %s/<a.\*\?href="\(.\{-}\)".\{-}>\(.\{-}\)<\/a>/[\2](\1)/g
endfunction


" file is large from 10mb
let g:LargeFile = 1024 * 1024 * 10
augroup LargeFile
 autocmd BufReadPre * let f=getfsize(expand("<afile>")) | if f > g:LargeFile || f == -2 | call LargeFile() | endif
augroup END

function LargeFile()
 " no line numbers, no ruler, etc
 set nonu noruler noai nosr
 " no syntax highlighting etc
 set eventignore+=FileType
 " save memory when other file is viewed
 setlocal bufhidden=unload
 " is read-only (write with :w new_filename)
 setlocal buftype=nowrite
 " no undo possible
 setlocal undolevels=-1
 " display message
 autocmd VimEnter *  echo "The file is larger than " . (g:LargeFile / 1024 / 1024) . " MB, so some options are changed (see .vimrc for details)."
endfunction



" WatchForChanges stuff. TODO: Put this in a plugin or something?
" From http://vim.wikia.com/wiki/Have_Vim_check_automatically_if_the_file_has_changed_externally

" If you are using a console version of Vim, or dealing
" with a file that changes externally (e.g. a web server log)
" then Vim does not always check to see if the file has been changed.
" The GUI version of Vim will check more often (for example on Focus change),
" and prompt you if you want to reload the file.
"
" There can be cases where you can be working away, and Vim does not
" realize the file has changed. This command will force Vim to check
" more often.
"
" Calling this command sets up autocommands that check to see if the
" current buffer has been modified outside of vim (using checktime)
" and, if it has, reload it for you.
"
" This check is done whenever any of the following events are triggered:
" * BufEnter
" * CursorMoved
" * CursorMovedI
" * CursorHold
" * CursorHoldI
"
" In other words, this check occurs whenever you enter a buffer, move the cursor,
" or just wait without doing anything for 'updatetime' milliseconds.
"
" Normally it will ask you if you want to load the file, even if you haven't made
" any changes in vim. This can get annoying, however, if you frequently need to reload
" the file, so if you would rather have it to reload the buffer *without*
" prompting you, add a bang (!) after the command (WatchForChanges!).
" This will set the autoread option for that buffer in addition to setting up the
" autocommands.
"
" If you want to turn *off* watching for the buffer, just call the command again while
" in the same buffer. Each time you call the command it will toggle between on and off.
"
" WatchForChanges sets autocommands that are triggered while in *any* buffer.
" If you want vim to only check for changes to that buffer while editing the buffer
" that is being watched, use WatchForChangesWhileInThisBuffer instead.
"
command! -bang WatchForChanges                  :call WatchForChanges(@%,  {'toggle': 1, 'autoread': <bang>0})
command! -bang WatchForChangesWhileInThisBuffer :call WatchForChanges(@%,  {'toggle': 1, 'autoread': <bang>0, 'while_in_this_buffer_only': 1})
command! -bang WatchForChangesAllFile           :call WatchForChanges('*', {'toggle': 1, 'autoread': <bang>0})

" WatchForChanges function
"
" This is used by the WatchForChanges* commands, but it can also be
" useful to call this from scripts. For example, if your script executes a
" long-running process, you can have your script run that long-running process
" in the background so that you can continue editing other files, redirects its
" output to a file, and open the file in another buffer that keeps reloading itself
" as more output from the long-running command becomes available.
"
" Arguments:
" * bufname: The name of the buffer/file to watch for changes.
"     Use '*' to watch all files.
" * options (optional): A Dict object with any of the following keys:
"   * autoread: If set to 1, causes autoread option to be turned on for the buffer in
"     addition to setting up the autocommands.
"   * toggle: If set to 1, causes this behavior to toggle between on and off.
"     Mostly useful for mappings and commands. In scripts, you probably want to
"     explicitly enable or disable it.
"   * disable: If set to 1, turns off this behavior (removes the autocommand group).
"   * while_in_this_buffer_only: If set to 0 (default), the events will be triggered no matter which
"     buffer you are editing. (Only the specified buffer will be checked for changes,
"     though, still.) If set to 1, the events will only be triggered while
"     editing the specified buffer.
"   * more_events: If set to 1 (the default), creates autocommands for the events
"     listed above. Set to 0 to not create autocommands for CursorMoved, CursorMovedI,
"     (Presumably, having too much going on for those events could slow things down,
"     since they are triggered so frequently...)
function! WatchForChanges(bufname, ...)
  " Figure out which options are in effect
  if a:bufname == '*'
    let id = 'WatchForChanges'.'AnyBuffer'
    " If you try to do checktime *, you'll get E93: More than one match for * is given
    let bufspec = ''
  else
    if bufnr(a:bufname) == -1
      echoerr "Buffer " . a:bufname . " doesn't exist"
      return
    end
    let id = 'WatchForChanges'.bufnr(a:bufname)
    let bufspec = a:bufname
  end

  if len(a:000) == 0
    let options = {}
  else
    if type(a:1) == type({})
      let options = a:1
    else
      echoerr "Argument must be a Dict"
    end
  end
  let autoread    = has_key(options, 'autoread')    ? options['autoread']    : 0
  let toggle      = has_key(options, 'toggle')      ? options['toggle']      : 0
  let disable     = has_key(options, 'disable')     ? options['disable']     : 0
  let more_events = has_key(options, 'more_events') ? options['more_events'] : 1
  let while_in_this_buffer_only = has_key(options, 'while_in_this_buffer_only') ? options['while_in_this_buffer_only'] : 0

  if while_in_this_buffer_only
    let event_bufspec = a:bufname
  else
    let event_bufspec = '*'
  end

  let reg_saved = @"
  "let autoread_saved = &autoread
  let msg = "\n"

  " Check to see if the autocommand already exists
  redir @"
    silent! exec 'au '.id
  redir END
  let l:defined = (@" !~ 'E216: No such group or event:')

  " If not yet defined...
  if !l:defined
    if l:autoread
      let msg = msg . 'Autoread enabled - '
      if a:bufname == '*'
        set autoread
      else
        setlocal autoread
      end
    end
    silent! exec 'augroup '.id
      if a:bufname != '*'
        "exec "au BufDelete    ".a:bufname . " :silent! au! ".id . " | silent! augroup! ".id
        "exec "au BufDelete    ".a:bufname . " :echomsg 'Removing autocommands for ".id."' | au! ".id . " | augroup! ".id
        exec "au BufDelete    ".a:bufname . " execute 'au! ".id."' | execute 'augroup! ".id."'"
      end
        exec "au BufEnter     ".event_bufspec . " :checktime ".bufspec
        exec "au CursorHold   ".event_bufspec . " :checktime ".bufspec
        exec "au CursorHoldI  ".event_bufspec . " :checktime ".bufspec

      " The following events might slow things down so we provide a way to disable them...
      " vim docs warn:
      "   Careful: Don't do anything that the user does
      "   not expect or that is slow.
      if more_events
        exec "au CursorMoved  ".event_bufspec . " :checktime ".bufspec
        exec "au CursorMovedI ".event_bufspec . " :checktime ".bufspec
      end
    augroup END
    let msg = msg . 'Now watching ' . bufspec . ' for external updates...'
  end

  " If they want to disable it, or it is defined and they want to toggle it,
  if l:disable || (l:toggle && l:defined)
    if l:autoread
      let msg = msg . 'Autoread disabled - '
      if a:bufname == '*'
        set noautoread
      else
        setlocal noautoread
      end
    end
    " Using an autogroup allows us to remove it easily with the following
    " command. If we do not use an autogroup, we cannot remove this
    " single :checktime command
    " augroup! checkforupdates
    silent! exec 'au! '.id
    silent! exec 'augroup! '.id
    let msg = msg . 'No longer watching ' . bufspec . ' for external updates.'
  elseif l:defined
    let msg = msg . 'Already watching ' . bufspec . ' for external updates'
  end

  " Do not spam me
  "echo msg
  let @"=reg_saved
endfunction

" Hopefully watch for changes to anything
WatchForChangesAllFile!
