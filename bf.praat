clearinfo

# consts (praat scriptでは大文字始まりの変数が宣言できないためgoogle記法使用)
kMemorySize = 30000

@main()


procedure main
    # input BF file name
    fileName$ = chooseReadFile$: "Choose BF file:"

    if fileName$ <> ""
        input$ = readFile$(fileName$)
        @eval(input$)
    endif
endproc


procedure eval(.input$)
    .memories# = zero#(kMemorySize)
    # NOTE: praatの添え字は1から始まる！！
    .ptr = 1
    .curTokenPos = 1
    .inputLen = length(.input$)

    while .curTokenPos <= .inputLen
        .curToken$ = mid$(.input$, .curTokenPos, 1)
        
        if .curToken$ == "+"
            # NOTE: vector要素に"+="演算子は使えない (ver6.1.04時点)
            .memories#[.ptr] = (.memories#[.ptr] + 1) mod 256
        elsif .curToken$ == "-"
            .memories#[.ptr] = (.memories#[.ptr] - 1) mod 256
        elsif .curToken$ == ">"
            .ptr = if .ptr >= kMemorySize then 0 else .ptr + 1 endif
        elsif .curToken$ == "<"
            .ptr = if .ptr = 0 then kMemorySize else .ptr - 1 endif
        elsif .curToken$ == "."
            # NOTE: unicodeは1~127の範囲はasciicodeと同じ
            appendInfo(unicode$(.memories#[.ptr]))
        elsif .curToken$ == ","
            @getChar()
            .memories#[.ptr] = unicode(getChar.return$)
        elsif .curToken$ == "["
            if .memories#[.ptr] == 0
                @matchedBracketClosePos(.input$, .curTokenPos)
                .curTokenPos = matchedBracketClosePos.return
            endif
        elsif .curToken$ == "]"
            if .memories#[.ptr] <> 0
                @matchedBracketOpenPos(.input$, .curTokenPos)
                .curTokenPos = matchedBracketOpenPos.return
            endif
        endif

        .curTokenPos += 1
    endwhile
endproc


procedure getChar()
    beginPause("input char:")
        comment("only first letter is set to memory")
        # HACK: フォームの引数をローカル変数にして名前汚染防ぐ
        # (フォームの引数は基本グローバル変数に代入されるので名前空間明示)
        text("getChar.gets", "")
    #    btn  default("OK") num of otherBtn 
    endPause("OK", 1)
    .return$ = left$(.gets$, 1)
endproc


procedure matchedBracketClosePos(.input$, .curTokenPos)
    .bracketNest = 1
    while .bracketNest > 0
        .curTokenPos += 1
        .curToken$ = mid$(.input$, .curTokenPos)
        if .curToken$ == "]"
            .bracketNest -= 1
        elsif .curToken$ == "["
            .bracketNest += 1
        endif 
    endwhile
    .return = .curTokenPos
endproc


procedure matchedBracketOpenPos(.input$, .curTokenPos)
    .bracketNest = 1
    while .bracketNest > 0
        .curTokenPos -= 1
        .curToken$ = mid$(.input$, .curTokenPos)
        if .curToken$ == "["
            .bracketNest -= 1
        elsif .curToken$ == "]"
            .bracketNest += 1
        endif 
    endwhile
    .return = .curTokenPos
endproc
