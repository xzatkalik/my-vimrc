set mouse=a
set modeline
set nohlsearch
set showmatch
set nobomb
set textwidth=0
syn on
if has("gui_running")
  set gfn=Source\ Code\ Pro\ Medium\ 16
  set guicursor+=a:blinkon0
  colorscheme solarized
  set guioptions-=m
  set guioptions-=T
  set guioptions-=r
else
  set bg=light
  colorscheme solarized
endif
set backup
set writebackup
set hidden
set wildmenu
set bs=2
filetype on
set dictionary+=mybib.bib
set dictionary+=keys.txt
set dictionary+=mykeys.txt
set fileencodings=utf-8

set incsearch


filetype plugin on
"let g:pymode_lint=0
let g:pymode_syntax_indent_errors=0
autocmd FileType python call FT_py()
autocmd FileType tex call FT_tex()
autocmd FileType c call FT_C()
autocmd FileType html call FT_html()
autocmd FileType htmldjango call FT_html()
autocmd FileType haskell call FT_hs()

map <F6> :bn
map <F5> :bp
nmap <silent> <F10> :wqa
nmap <silent> <F2> :w
imap <F6> :bn
imap <F5> :bp
imap <F10> <F10>
imap <F2> <F2>i

function FindBegin() 

	let i=line(".")-1
	let cnt=0
	while i>=1
		let str=getline(i)
		if (str=~'end{.*}')
			 let cnt=cnt+1
		endif
		if (str=~'begin{.*}')
			 let cnt=cnt-1
		endif
		if (cnt < 0)
			return i
		endif
		let i=i-1
	endwhile
	return -1
endfunction

function FindEnd() 

	let i=line(".")+1
	let cnt=0
	while i<=line("$")
		let str=getline(i)
		if (str=~'begin{.*}')
			 let cnt=cnt+1
		endif
		if (str=~'end{.*}')
			 let cnt=cnt-1
		endif
		if (cnt < 0)
			return i
		endif
		let i=i+1
	endwhile
	return -1
endfunction

function PutBegin()

	let end=FindEnd()
	if (end>0)
		let @u=getline(end)
		exec "normal \"uP"
		exec ".s/end/begin/"
	endif
endfunction

function PutEnd()

	let beg=FindBegin()
	if (beg>0)
		let @u=getline(beg)
		exec "normal ik\"uP"
		exec ".s/begin{\\([^}]*\\)}.*/end{\\1}/"
	endif
endfunction

function FT_C()
set ofu=syntaxcomplete#Complete
map <F9> :wa:!cc -lm %
map <F3> :wa:!cc -lm %:!./a.out
endfunction

function FT_hs()
set ai 
set ts=4 
set sts=4 
set et 
set sw=4
nmap <F9> :wa:echo system("cd ".expand("%:p:h").";"."runhaskell ".expand("%:p"))
imap <F9> :wa:echo system("cd ".expand("%:p:h").";"."runhaskell ".expand("%:p"))i
endfunction


function FT_html()
set ai 
set ts=2 
set sts=2 
set et 
set sw=2
set omnifunc=syntaxcomplete#Complete
endfunction

function FT_py()
set ai 
set ts=4 
set sts=4 
set et 
set sw=4
set omnifunc=pythoncomplete#Complete
let g:pyversion="python3"
if getline(1)=~'python2'
	let g:pyversion="python2"
endif

nmap <F9> :wa:echo system("cd ".expand("%:p:h").";".g:pyversion." ".expand("%:p"))
imap <F9> :wa:echo system("cd ".expand("%:p:h").";".g:pyversion." ".expand("%:p"))i
let g:pymode_lint=0
highlight Error NONE
endfunction


function TeX_foldexpr(lnum)
	
	if getline(a:lnum+1)=~'\\section'
		return '<1'
	else
		return '1'
	endif
endfunction

function InsertTabWrapper()
      let col = col('.') - 1
      if !col || getline('.')[col - 1] !~ '\k'
          return "\<tab>"
      else
          return "\<c-p>"
      endif
endfunction


function! SyncTexForward()
     let execstr = "!okular --unique %:p:r.pdf\\#src:".line(".")."%:p 2>/dev/null&"
     exec execstr
endfunction

function FT_tex()

set textwidth=90
set foldexpr=TeX_foldexpr(v:lnum)
set foldmethod=expr
set foldlevel=1
set iskeyword=134,@,48-57,_,192-255,:
set complete=.,w,b,u,t,i,k

let g:dviview='xdvi'
let g:psview='gv'

map [[ ?\\section
map ]] /\\section

let i=1
let g:beamer=0
while i<20
	if getline(i)=~"documentclass.*beamer"
		let g:beamer=1
		break
	endif
	let i=i+1
endwhile	

if g:beamer==1
		setlocal makeprg=echo\ pdflatex\ %\;pdflatex\ --synctex=1\ -src-specials\ --file-line-error\ --interaction\ nonstopmode\ %\ \\\|\ grep\ '^[^:]*:[0123456789]*:'
else
		setlocal makeprg=echo\ xelatex\ %\;xelatex\ --synctex=1\ \ -src-specials\ --file-line-error\ --interaction\ nonstopmode\ %\ \\\|\ grep\ '^[^:]*:[0123456789]*:'
endif

set errorformat=%f:%l:%m

nnoremap <Tab><F3> :execute "!cd ".expand("%:p:h").";".g:psview." ".expand("%:p:r").".ps &"
nnoremap <buffer> <F3> :call SyncTexForward()<CR>
map <F9> <F2>:make<CR>
imap <F9> <F9>
inoremap <C-E> :call PutEnd()i
inoremap <C-B> :call PutBegin()i
inoremap <tab> <c-r>=InsertTabWrapper()<cr>

syn sync clear
syn sync fromstart

endfunction
				
