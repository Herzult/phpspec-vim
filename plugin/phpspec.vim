if exists('g:loaded_phpspec') && g:loaded_phpspec
    finish
endif

let g:loaded_phpspec = 1

function PhpSpecDesc()
    call inputsave()
    let class = input('Please enter the class name: ')
    call inputrestore()
    if class == ''
        echo 'That was too short!'
        return 0
    endif
    echo system('./bin/phpspec desc '.class)
    call PhpSpecGotoSpec(class)
endfunction

function PhpSpecRun()
    !./bin/phpspec run -fpretty
endfunction

function PhpSpecGotoSpec(class)
    execute 'edit spec/'.a:class.'.php'
endfunction

function PhpSpecGotoSource(class)
    execute 'edit src/'.a:class.'.php'
endfunction

function PhpSpecSwitch()
    let curFile = expand('%')
    let pattern = '\(spec\|src\)\/\(.\+\)\.php'
    let matches = matchlist(curFile, pattern)

    if len(matches) == 0
        echom 'Cannot determine current class.'
        return 0
    endif

    let curSide  = matches[1]
    let curClass = matches[2]

    if curSide == 'src'
        return PhpSpecGotoSpec(curClass)
    else
        return PhpSpecGotoSource(curClass)
    endif
endfunction

"
" define some mapping
"
map <silent> <leader>spr :call PhpSpecRun()<cr>
map <leader>spd :call PhpSpecDesc()<cr>
map <silent> <leader>sps :call PhpSpecSwitch()<cr>
