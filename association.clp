(defrule switch-xb-to-bx
    ; ....... (  a +- ( coef  *  x ) )     ......
    ?old-fact <- (equation $?first 
        mult ?id 
            x
        split ?id 
            ?a&:(numberp ?a)
        end ?id
    $?last)
    =>
    (retract ?old-fact)
    (assert (equation ?first 
        mult ?id ?a split ?id x end ?id 
    ?last)
    )
)

; transforms (a (+-) bx) ==>  ((+-) bx + a)
(defrule switch-bx-to-first
    ; ....... (  a +- ( coef  *  x ) )     ......
    ?old-fact <- (equation $?first 
        ?operator ?id 
            ?a&:(numberp ?a) 
        split ?id 
            mult ?id2 ?coef split ?id2 x  end ?id2 
        end ?id 
    $?last)
    =>
    (switch ?operator
        (case add then 
            ;         ....... (       (         coef  *          x )        +         a         )......
            (assert (equation $?first add ?id mult ?id2 ?coef split ?id2 x end ?id2 split ?id ?a end ?id $?last))
            (retract ?old-fact)
        )(case sub then
            ;         ....... (       (          - coef      *          x )        +         a         )......
            (assert (equation $?first add ?id mult ?id2 (- 0 ?coef) split ?id2 x end ?id2 split ?id ?a end ?id $?last))
            (retract ?old-fact)
        )(default)
    )
)

; Association Rule
; transforms (((a [*3] x) [+-2] b) [+-1] (c [*4] x)) ==>  (((a [+-1] c) [*3] x) [+-2] b)
(defrule association-rules-1
    ?old-fact <- (equation $?first 
        ?operator1 ?id 
            ?operator2 ?id2
                mult ?id3 
                    ?a&:(numberp ?a) 
                split ?id3 
                    x 
                end ?id3 
            split ?id2 
                ?b&:(numberp ?b) 
            end ?id2
        split ?id 
            mult ?id4 
                ?c&:(numberp ?c) 
            split ?id4 
                x 
            end ?id4
        end ?id
    $?last)
    =>
    (switch ?operator1
        (case add then
            (assert (equation ?first
                ?operator2 ?id2
                    mult ?id3 (+ ?a ?c) split ?id3 x end ?id3
                split ?id2
                    ?b
                end ?id2
            ?last))
            (retract ?old-fact)
        )(case sub then
            (assert (equation ?first
                ?operator2 ?id2
                    mult ?id3 (- ?a ?c) split ?id3 x end ?id3
                split ?id2
                    ?b
                end ?id2
            ?last))
            (retract ?old-fact)
        )(default)
    )
)
