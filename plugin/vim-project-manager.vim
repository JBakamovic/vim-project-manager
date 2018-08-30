"
" Sanity checks
"
if exists ("g:loaded_project_manager")
    finish
endif
let g:loaded_project_manager = 1

"
" Store cpo
"
let s:save_cpo = &cpo
set cpo&vim

"
" Configurable variables
"
let g:proj_mgr_automatically_save_session_on_close = v:true
let g:proj_mgr_automatically_save_modified_files_on_save = v:false
let g:proj_mgr_blacklisted_session_entries = [
\   'NERD_tree',
\   'NERDTree',
\   'Tagbar'
\]

"
" Commands
"
:command! -nargs=0 -complete=file ProjectNew    :call project#new()
:command! -nargs=0 -complete=file ProjectOpen   :call project#open()
:command! -nargs=0 -complete=file ProjectImport :call project#import()
:command! -nargs=0 -complete=file ProjectClose  :call project#close()
:command! -nargs=0 -complete=file ProjectSave   :call project#save()

"
" Mappings
"
nmap        <C-s>n              :ProjectNew<CR>		|" New project
nmap        <C-s>o              :ProjectOpen<CR>	|" Open project
nmap        <C-s>i              :ProjectImport<CR>	|" Import project
nmap        <C-s>c              :ProjectClose<CR>	|" Close project
nmap        <C-s>s              :ProjectSave<CR>	|" Save project

"
" restore cpo
"
let &cpo = s:save_cpo
unlet s:save_cpo

