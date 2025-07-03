"" My Vim config

set runtimepath+=~/.vim

:set mouse=a

nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap <C-n> :NERDTree<CR>
nnoremap <C-t> :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFind<CR>

" Remap hjkl to jkl;
noremap j h
noremap k j
noremap l k
noremap ; l

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Plugins
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

call plug#begin()

" List your plugins here

Plug 'preservim/nerdtree'
"Plug 'itchyny/lightline.vim'
Plug 'tpope/vim-sensible'
Plug 'dylanaraps/wal.vim'

call plug#end()


colorscheme wal
set number
