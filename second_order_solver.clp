; Second Order Solver
; num1 [operator] F(x) = rhs_num 
; --> F(x) = rhs_num [inverse_operator] num1
(defrule solve-quadratic-equation
    ?old-fact <- (
    equation
        add ?id1
            mult ?id2
                mult ?id3
                    x
                split ?id3
                    x
                end ?id3
            split ?id2
                ?A&:(numberp ?A)
            end ?id2
        split ?id1
            add ?id4
                mult ?id2
                    x
                split ?id2
                    ?B&:(numberp ?B)
                end ?id2
            split ?id4
                ?C&:(numberp ?C)
            end ?id4
        end ?id1
    equal ?rhs_num&:(numberp ?rhs_num)
    ))
    =>
    (retract ?old-fact)
    (bind ?C ?C-?rhs_num)
    (assert (equation x equal (/ (- -?B (sqrt (- (* ?B ?B) (* 4 (* ?A ?C))))) (* 2 ?A)), (/ (+ -?B (sqrt (- (* ?B ?B) (* 4 (* ?A ?C))))) (* 2 ?A)) ))
)

;rules to standardize structure of statement

;standardize association of terms
; x*x*a + (x*b + c) => (x*x*a + x*b) + c
(defrule solve-quadratic-equation
    ?old-fact <- (
    equation
        add ?id1
            add ?id4
                mult ?id2
                    mult ?id3
                        x
                    split ?id3
                        x
                    end ?id3
                split ?id2
                    ?A&:(numberp ?A)
                end ?id2
            split ?id4
                mult ?id2
                    x
                split ?id2
                    ?B&:(numberp ?B)
                end ?id2
            end ?id4
        split ?id1
            ?C&:(numberp ?C)
        end ?id1
    equal ?rhs_num&:(numberp ?rhs_num)
    ))
    =>
    (retract ?old-fact)
    (bind ?C ?C-?rhs_num)
    (assert (equation
        add ?id1
            mult ?id2
                mult ?id3
                    x
                split ?id3
                    x
                end ?id3
            split ?id2
                ?A
            end ?id2
        split ?id1
            add ?id4
                mult ?id2
                    x
                split ?id2
                    ?B
                end ?id2
            split ?id4
                ?C
            end ?id4
        end ?id1
    equal ?rhs_num))
)


; x*b + x*x*a => x*x*a + x*b
(defrule solve-quadratic-equation
    ?old-fact <- (
    $?first
        add ?id1
            mult ?id2
                x
            split ?id2
                ?B
            end ?id2
        split ?id1
            mult ?id3
                mult ?id4
                    x
                split ?id4
                    x
                end ?id4
            split ?id3
                ?A
            end ?id3
        end ?id1
    $?last
    )
    =>
    (retract ?old-fact)
    (assert ($?first
        add ?id1
            mult ?id3
                mult ?id4
                    x
                split ?id4
                    x
                end ?id4
            split ?id3
                ?A
            end ?id3
        split ?id1
            mult ?id2
                x
            split ?id2
                ?B
            end ?id2
        end ?id1
    $?last
)))

; c + x*b => x*b + c
(defrule solve-quadratic-equation
    ?old-fact <- (
    $?first
        add ?id1
            ?C&:(numberp ?C)
        split ?id1
            mult ?id2
                x
            split ?id2
                ?B&:(numberp ?B)
            end ?id2
        end ?id1
    $?last)
    ))
    =>
    (retract ?old-fact)
    (assert (
    $?first
        add ?id1
            mult ?id2
                x
            split ?id2
                ?B
            end ?id2
        split ?id1
            ?C
        end ?id1
    $?last
)

; S - C => S + -c
; get rid of subs
(defrule solve-quadratic-equation
    ?old-fact <- (
    $?first
        sub ?id1
            $?opd1
        split ?id1
            ?C&:(numberp ?C)
        end ?id1
    $?last)
    ))
    =>
    (retract ?old-fact)
    (assert (
    $?first
        add ?id1
            $?opd1
        split ?id1
            -?C
        end ?id1
    $?last
)

; S - x*x*a => S + x*x*(-a)
; get rid of subs
(defrule solve-quadratic-equation
    ?old-fact <- (
    $?first
        sub ?id1
            $?opd1
        split ?id1
            mult ?id3
                mult ?id4
                    x
                split ?id4
                    x
                end ?id4
            split ?id3
                ?A&:(numberp ?A)
            end ?id3
        end ?id1
    $?last)
    ))
    =>
    (retract ?old-fact)
    (assert (
    $?first
        add ?id1
            $?opd1
        split ?id1
            mult ?id3
                mult ?id4
                    x
                split ?id4
                    x
                end ?id4
            split ?id3
                -?A
            end ?id3
        end ?id1
    $?last
)

; S - x*b => S + x*(-b)
; get rid of subs
(defrule solve-quadratic-equation
    ?old-fact <- (
    $?first
        sub ?id1
            $?opd1
        split ?id1
            mult ?id3
                x
            split ?id3
                ?B&:(numberp ?B)
            end ?id3
        end ?id1
    $?last)
    ))
    =>
    (retract ?old-fact)
    (assert (
    $?first
        add ?id1
            $?opd1
        split ?id1
            mult ?id3
                x
            split ?id3
                -?B
            end ?id3
        end ?id1
    $?last
)