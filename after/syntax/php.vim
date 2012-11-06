if !has('conceal') || &enc != 'utf-8'
    finish
endif

if !exists('g:phpspec_conceal') || g:phpspec_conceal
    syntax match phpspecExampleName / \(its\|it\)_[^(]*/ contained containedin=phpRegion
    syntax match phpspecExampleSubject / \(its_[^_]*\|it\)/ contained containedin=phpspecExampleName
    syntax match phpspecExampleDelimiter "_" conceal cchar=  contained containedin=phpspecExampleName,phpspecExampleSubject

    setlocal conceallevel=2

    highlight! link Conceal Operator
endif
