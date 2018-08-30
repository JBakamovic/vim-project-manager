let s:project_session_loaded   = v:false
let s:project_session_filename = '.vimproj'

function! project#new()
    " Close any previously opened projects if any
    call project#close()

    " Ask user to provide name of a project directory to be created
    call inputsave()
    let l:project_name = input('Project name: ')
    call inputrestore()

    if l:project_name == ""
	    echohl WarningMsg | echomsg "You need to provide a valid (non-empty) project name!" | echohl None
        return v:false
    endif

    " Ask user to provide a project root directory
    call inputsave()
    let l:project_root_directory = input('Project directory: ', '', 'dir')
    call inputrestore()

    if isdirectory(l:project_root_directory) == 0
	    echohl WarningMsg | echomsg "You need to provide a valid (existing) directory path!" | echohl None
        return v:false
    endif

    " Create project root directory for a new project
    let l:project_root_directory = l:project_root_directory . '/' . l:project_name
    call mkdir(l:project_root_directory, "p")
    
    " Set cwd to the project directory
    execute('cd ' . l:project_root_directory)

    " Store initial project session file
    execute('mksession! ' . s:project_session_filename)

    " Session is loaded
    let s:project_session_loaded = v:true

    return v:true
endfunction

function! project#import()
    " Close any previously opened projects if any
    call project#close()

    " Ask user to provide a project root directory
    call inputsave()
    let l:project_root_directory = input('Project directory: ', '', 'dir')
    call inputrestore()

    if isdirectory(l:project_root_directory) == 0
	    echohl WarningMsg | echomsg "You need to provide a valid (existing) directory path!" | echohl None
        return v:false
    endif
    
    " Set cwd to the project directory
    execute('cd ' . l:project_root_directory)

    " Store initial project session file
    execute('mksession! ' . s:project_session_filename)

    " Session is loaded
    let s:project_session_loaded = v:true
    
    return v:true
endfunction

function! project#open()
    " Close any previously opened projects if any
    call project#close()

    " Ask user to provide a project root directory
    call inputsave()
    let l:project_root_directory = input('Project directory: ', '', 'dir')
    call inputrestore()

    if isdirectory(l:project_root_directory) == 0
	    echohl WarningMsg | echomsg "You need to provide a valid (existing) directory path!" | echohl None
        return v:false
    endif

    " Set cwd to the project directory
    execute('cd ' . l:project_root_directory)
        
    " Load existing project session file
    let s:project_session_loaded = v:false
    if filereadable(s:project_session_filename)
        execute('source ' . s:project_session_filename)
        let s:project_session_loaded = v:true
    else
        execute('cd ~/')
        redraw | echohl WarningMsg | echomsg "No project found at '" . l:project_root_directory . "'" | echohl None
        return v:false
    endif

    return v:true
endfunction

function! project#close()
    if s:project_session_loaded == v:false
        return 1
    endif

    " Save session automatically. Or ask user if he wants to save the session.
    if g:proj_mgr_automatically_save_session_on_close || confirm("Save all changes made to this session?", "&Yes\n&No", v:true) == v:true
        call project#save()
    endif

    " Close all buffers
    execute('%bd!')

    " Close all but the current window
    if winnr('$') > 1
        execute 'only!'
    endif

    " Close all but the current tab
    if tabpagenr('$') > 1
        execute('tabonly!')
    endif

    " Reset the working directory
    execute('cd ~/')

    " Reset the session
    let v:this_session = ''
    let s:project_session_loaded = v:false
endfunction

function! project#save()
    if s:project_session_loaded == v:false
        return 1
    endif

    " Save files automatically. Or ask user if he wants to save all modified files.
    if g:proj_mgr_automatically_save_modified_files_on_save || confirm("Save changes made to files?", "&Yes\n&No", v:true) == v:true
        execute('wa')
    endif

    " Save Vim session
    execute('mksession! ' . s:project_session_filename)

    " Remove blacklisted session entries
    let cmd = 'sed -i ' . '"' . '\:' . join(g:proj_mgr_blacklisted_session_entries, '\|') . ':d' . '" ' . s:project_session_filename
    let resp = system(cmd)
endfunction

