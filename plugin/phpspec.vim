if exists('g:loaded_phpspec') && g:loaded_phpspec
    finish
endif

let g:loaded_phpspec = 1

if !exists('g:phpspec_executable')
    if filereadable('./bin/phpspec')
        let g:phpspec_executable = './bin/phpspec'
    elseif filereadable('./vendor/bin/phpspec')
        let g:phpspec_executable = './vendor/bin/phpspec'
    elseif filereadable('./vendor/phpspec/phpspec/bin/phpspec')
        let g:phpspec_executable = './vendor/phpspec/phpspec/bin/phpspec'
    else
        " fallback to path
        let g:phpspec_executable = 'phpspec'
    endif
endif

if !exists('g:phpspec_command')
  let g:phpspec_command = '!{command}'
endif

if !exists('g:phpspec_spec_directory')
    let g:phpspec_spec_directory = './spec'
endif

if !exists('g:phpspec_spec_namespace')
    let g:phpspec_spec_namespace = 'spec\\'
endif

if !exists('g:phpspec_source_directory')
    let g:phpspec_source_directory = './src'
endif

if (!exists('g:phpspec_default_mapping') || g:phpspec_default_mapping)
    map <silent> <leader>spr :PhpSpecRun<cr>
    map <silent> <leader>spc :PhpSpecRunCurrent<cr>
    map <leader>spd :PhpSpecDesc 
    map <silent> <leader>sps :PhpSpecSwitch<cr>
endif

if !exists('g:phpspec_run_cmd_options')
    if (has("gui_running")) 
        let g:phpspec_run_cmd_options = '--no-ansi'
    else
        let g:phpspec_run_cmd_options = '-fpretty'
    endif
endif

if !exists('g:phpspec_desc_cmd_options')
    if (has("gui_running")) 
        let g:phpspec_desc_cmd_options = '--no-ansi'
    else
        let g:phpspec_desc_cmd_options = ''
    endif
endif

command -nargs=0 PhpSpecRun          call phpspec#run()
command -nargs=0 PhpSpecRunCurrent   call phpspec#runCurrentClass()
command -nargs=1 PhpSpecDesc         call phpspec#descClass(<f-args>)
command -nargs=1 PhpSpecOpenSpec     call phpspec#openSpec(<f-args>)
command -nargs=1 PhpSpecOpenSource   call phpspec#openSource(<f-args>)
command -nargs=0 PhpSpecSwitch       call phpspec#switch()


function phpspec#descClass(class)
    execute phpspec#getDescCommand(a:class)
    call phpspec#openSpec(a:class)
endfunction

function phpspec#runCurrentClass()
    try
      let class = phpspec#getCurrentClass()
    catch
      let class = phpspec#getLastClass()
    endtry
    call phpspec#runClass(phpspec#getSpecFile(class))
    call phpspec#setLastClass(class)
endfunction

function phpspec#run(...)
    let class = a:0 > 0 ? a:1 : ''
    call phpspec#runClass(class)
endfunction

function phpspec#runClass(class)
    execute phpspec#getRunClassCommand(a:class)
endfunction

function phpspec#switch()
    let class = phpspec#getCurrentClass()
    if phpspec#getCurrentFile() == phpspec#getSpecFile(class)
        call phpspec#openSource(class)
    else
        call phpspec#openSpec(class)
    endif
endfunction

function phpspec#openSpec(class)
    if a:class == ''
        let a:class = phpspec#getCurrentClass()
    endif
    let file = phpspec#getSpecFile(a:class)
    if bufexists(file)
        execute(printf('buffer %s', file))
        return
    endif
    if filereadable(file)
        execute(printf('edit %s', file))
        return
    endif
    if 1 == confirm('No spec yet, would you like to create it?', "&Yes\n&No")
        return phpspec#descClass(a:class)
    endif
endfunction

function phpspec#openSource(class)
    if a:class == ''
        let a:class = phpspec#getCurrentClass()
    endif
    let file = phpspec#getSourceFile(a:class)
    if bufexists(file)
        execute(printf('buffer %s', file))
        return
    endif
    execute(printf('edit %s', file))
endfunction

function phpspec#getDescCommand(class)
    return printf('%s desc %s %s', g:phpspec_executable, g:phpspec_desc_cmd_options, a:class)
endfunction

function phpspec#getRunClassCommand(class)
    let command = printf('%s run %s %s', g:phpspec_executable, g:phpspec_run_cmd_options, a:class)
    return phpspec#getPhpspecCommand(command)
endfunction

function phpspec#getPhpspecCommand(command)
    return substitute(g:phpspec_command, '{command}', a:command, 'g')
endfunction

function phpspec#getSpecFile(class)
    return fnamemodify(printf('%s/%sSpec.php', g:phpspec_spec_directory, a:class), ':p')
endfunction

function phpspec#getSourceFile(class)
    return fnamemodify(printf('%s/%s.php', g:phpspec_source_directory, a:class), ':p')
endfunction

function phpspec#getCurrentClass()
    return phpspec#getClass(phpspec#getCurrentFile())
endfunction

function phpspec#getCurrentFile()
    return expand('%:p')
endfunction

function phpspec#getLastClass()
    if exists('s:last_class')
      return s:last_class
    else
      throw 'Current and last files are not specs nor source files.'
    endif
endfunction

function phpspec#setLastClass(class)
    let s:last_class = a:class
endfunction

function phpspec#getClass(path)
    " are we in a spec file?
    let matches = matchlist(a:path, printf('^%s\(.\+\)Spec\.php$', fnamemodify(g:phpspec_spec_directory, ':p')))
    if len(matches) > 0
        return matches[1]
    endif
    " are we in a source file?
    let matches = matchlist(a:path, printf('^%s\(.\+\)\.php$', fnamemodify(g:phpspec_source_directory, ':p')))
    if len(matches) > 0
        return matches[1]
    endif
    throw 'Current file is not a spec nor source file.'
endfunction


