if exists('g:loaded_phpspec') && g:loaded_phpspec
    finish
endif

let g:loaded_phpspec = 1

if !exists('g:phpspec_executable')
    let g:phpspec_executable = './bin/phpspec'
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

function phpspec#desc()
    call inputsave()
    let class = input('Please enter the class name: ')
    call inputrestore()
    if class == ''
        echo 'That was too short!'
        return 0
    endif
    call phpspec#descClass(class)
    call phpspec#openSpec(class)
endfunction

function phpspec#run()
    call phpspec#runClass('')
endfunction

function phpspec#runCurrentClass()
    call phpspec#runClass(phpspec#getCurrentClass())
endfunction

function phpspec#switch()
    let class = phpspec#getCurrentClass()
    let current = expand('%:p')
    if current == phpspec#getSpecFile(class)
        call phpspec#openSource(class)
    else
        call phpspec#openSpec(class)
    endif
endfunction

function phpspec#descClass(class)
    execute(printf('!%s', phpspec#getDescCommand(a:class)))
endfunction

function phpspec#openSpec(class)
    execute(printf('edit %s', phpspec#getSpecFile(a:class)))
endfunction

function phpspec#openSource(class)
    execute(printf('edit %s', phpspec#getSourceFile(a:class)))
endfunction

function phpspec#runClass(class)
    execute(printf('!%s', phpspec#getRunClassCommand(a:class)))
endfunction

function phpspec#getDescCommand(class)
    let parts = [g:phpspec_executable, 'desc', a:class]

    add(parts, printf('--src-path=%s', g:phpspec_source_directory))
    add(parts, printf('--spec-path=%s', g:phpspec_spec_directory))
    add(parts, printf('--spec-namespace=%s', g:phpspec_spec_namespace))

    return join(parts, ' ')
endfunction

function phpspec#getRunClassCommand(class)
    return printf('%s run -fpretty %s', g:phpspec_executable, a:class)
endfunction

function phpspec#getSpecFile(class)
    return fnamemodify(printf('%s/%s.php', g:phpspec_spec_directory, a:class), ':p')
endfunction

function phpspec#getSourceFile(class)
    return fnamemodify(printf('%s/%s.php', g:phpspec_source_directory, a:class), ':p')
endfunction

function phpspec#getCurrentClass()
    let current = expand('%:p')
    " are we in a spec file?
    let matches = matchlist(current, printf('^%s\(.\+\)\.php$', fnamemodify(g:phpspec_spec_directory, ':p')))
    if len(matches) > 0
        return matches[1]
    endif
    " are we in a source file?
    let matches = matchlist(current, printf('^%s\(.\+\)\.php$', fnamemodify(g:phpspec_source_directory, ':p')))
    if len(matches) > 0
        return matches[1]
    endif
    throw 'Current file is not a spec nor source file.'
endfunction

"
" define some mapping
"
map <silent> <leader>spr :call phpspec#run()<cr>
map <silent> <leader>spc :call phpspec#runCurrentClass()<cr>
map <leader>spd :call phpspec#desc()<cr>
map <silent> <leader>sps :call phpspec#switch()<cr>
