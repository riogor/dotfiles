filetype plugin indent on "плагины для Vim
set nocompatible
 
"Редактор
set encoding=utf-8
syntax enable
set tabstop=4
set number
 
 
"установщик плагинов
if empty(glob('~/.vim/autoload/plug.vim')) "установка установщика
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC 
endif
 
"плагины тута
call plug#begin('~/.vim/bundle')
"Plug 'valloric/youcompleteme'
"Plug 'ErichDonGubler/vim-sublime-monokai' "Тема из  саблайма
Plug 'tomasiser/vim-code-dark' "VSCode theme
Plug 'vim-airline/vim-airline' "Панелька
Plug 'ryanoasis/vim-devicons' "Иконочки
"Plug 'lervag/vimtex' "Латех
"Plug 'xavierd/clang_complete'
call plug#end()
 
set background=dark
colorscheme codedark "Тема
"Статус-панелька
let g:airline_powerline_fonts = 1
let g:airline#extensions#keymap#enabled = 0
let g:airline_section_z = "\ue0a1:%l/%L Col:%c"
let g:Powerline_symbols = 'unicode'
let g:airline#extensions#xkblayout#enabled = 0
let g:clang_library_path = '/usr/lib/libclang.so.15.0.7' 
"Шрифтек
set guifont=JetBrains\ Mono\ Light\ Nerd\ Font\ Complete:h20
 
"Настройки латеха
let g:vimtex_view_method = 'mupdf'
let g:vimtex_compiler_method = 'latexmk'
let g:vimtex_complete_enabled = 1
 
let maplocalleader = ","
 
 
