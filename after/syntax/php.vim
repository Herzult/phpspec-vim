if !has('conceal') || &enc != 'utf-8'
    finish
endif

syntax match phpspecExampleName / \(its\|it\)_[^(]*/ contained containedin=phpRegion
syntax match phpspecExampleSubject / \(its_[^_]*\|it\)/ contained containedin=phpspecExampleName
syntax match phpspecExampleDelimiter "_" conceal cchar=  contained containedin=phpspecExampleName,phpspecExampleSubject

setlocal conceallevel=2
