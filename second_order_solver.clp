; Second Order Solver
; num1 [operator] F(x) = rhs_num 
; --> F(x) = rhs_num [inverse_operator] num1
(defrule solve-quadratic-equation
    ?old-fact <- (equation 
        add ?id5 
            mult ?id4 
                ?A&:(numberp ?A) 
            split ?id4 
                mult ?id3 
                    x 
                split ?id3 
                    x 
                end ?id3 
            end ?id4 
        split ?id5 
            add ?id2 
                mult ?id1 
                    ?B&:(numberp ?B) 
                split ?id1 
                    x 
                end ?id1 
            split ?id2 
                ?C&:(numberp ?C) 
            end ?id2 
        end ?id5 
    equal ?rhs&:(numberp ?rhs)
    ) =>
    (retract ?old-fact)
    (bind ?C (- ?C ?rhs))
    (if (< (- (* ?B ?B) (* 4 (* ?A ?C))) 0)
        then 
            (assert (equation x equal (sym-cat (/ (- 0 ?B) (* 2 ?A)) - (/ (sqrt (- (* ?B ?B) (* 4 (* ?A ?C)))) (* 2 ?A)) i) (sym-cat (/ (- 0 ?B) (* 2 ?A)) + (/ (sqrt (- (* ?B ?B) (* 4 (* ?A ?C)))) (* 2 ?A)) i)))
        else
            (assert (equation x equal (/ (- (- 0 ?B) (sqrt (- (* ?B ?B) (* 4 (* ?A ?C))))) (* 2 ?A)) (/ (+ (- 0 ?B) (sqrt (- (* ?B ?B) (* 4 (* ?A ?C))))) (* 2 ?A))))
    )
)

; Second Order Solver
; num1 [operator] F(x) = rhs_num 
; --> F(x) = rhs_num [inverse_operator] num1
(defrule solve-quadratic-equation2
    ?old-fact <- (equation 
        add ?id1 
            mult ?id2 
                ?A&:(numberp ?A) 
            split ?id2 
                mult ?id3 
                    x 
                split ?id3 
                    x 
                end ?id3 
            end ?id2 
        split ?id1 
            mult ?id5 
                ?B&:(numberp ?B)
            split ?id5 
                x 
            end ?id5 
        end ?id1 
    equal ?rhs&:(numberp ?rhs))
    =>
    (retract ?old-fact)
    (bind ?C (- 0 ?rhs))
    (if (< (- (* ?B ?B) (* 4 (* ?A ?C))) 0)
        then 
            (assert (equation x equal (sym-cat (/ (- 0 ?B) (* 2 ?A)) - (/ (sqrt (- 0 (- (* ?B ?B) (* 4 (* ?A ?C))))) (* 2 ?A)) i) (sym-cat (/ (- 0 ?B) (* 2 ?A)) + (/ (sqrt (- 0 (- (* ?B ?B) (* 4 (* ?A ?C))))) (* 2 ?A)) i)))
        else
            (assert (equation x equal (/ (- (- 0 ?B) (sqrt (- (* ?B ?B) (* 4 (* ?A ?C))))) (* 2 ?A)) (/ (+ (- 0 ?B) (sqrt (- (* ?B ?B) (* 4 (* ?A ?C))))) (* 2 ?A))))
    )
)

;rules to standardize structure of statement

;standardize association of terms
; x*x*a + (x*b + c) => (x*x*a + x*b) + c
(defrule turn-x-into-1x
    ?old-fact <- (
    equation
        $?first 
            add ?id
                x
            split ?id
                $?anything
            end ?id
        $?rest
    )
    =>
    (retract ?old-fact)
    (assert (equation
        ?first 
            add ?id
                mult ?*next_id* 
                    1 
                split ?*next_id* 
                    x 
                end ?*next_id*
            split ?id
                ?anything
            end ?id
        ?rest))
    (bind ?*next_id* (+ ?*next_id* 1))

)
(defrule turn-x-into-1x-2
    ?old-fact <- (
    equation
        $?first 
            add ?id
                $?anything
            split ?id
                x
            end ?id
        $?rest
    )
    =>
    (retract ?old-fact)
    (assert (equation
        ?first 
            add ?id
                ?anything
            split ?id
                mult ?*next_id* 
                    1 
                split ?*next_id* 
                    x 
                end ?*next_id*
            end ?id
        ?rest))
    (bind ?*next_id* (+ ?*next_id* 1))

)


;standardize association of terms
; x*x*a + (x*b + c) => (x*x*a + x*b) + c
(defrule standardize-quadratic-equation
    ?old-fact <- (
    equation
        add ?id1
            add ?id4
                mult ?id2
                    ?A&:(numberp ?A)
                split ?id2
                    mult ?id3
                        x
                    split ?id3
                        x
                    end ?id3
                end ?id2
            split ?id4
                mult ?id2
                    ?B&:(numberp ?B)
                split ?id2
                    x
                end ?id2
            end ?id4
        split ?id1
            ?C&:(numberp ?C)
        end ?id1
    equal ?rhs_num&:(numberp ?rhs_num)
    )
    =>
    (retract ?old-fact)
    (bind ?C (- ?C ?rhs_num))
    (assert (equation
        add ?id1
            mult ?id2
                ?A
            split ?id2
                mult ?id3
                    x
                split ?id3
                    x
                end ?id3
            end ?id2
        split ?id1
            add ?id4
                mult ?id2
                    ?B
                split ?id2
                    x
                end ?id2
            split ?id4
                ?C
            end ?id4
        end ?id1
    equal ?rhs_num))
)


; x*b + x*x*a => x*x*a + x*b
(defrule flip-x2-and-x
    ?old-fact <- (equation $?first
        add ?id1
            mult ?id2
                ?B&:(numberp ?B)
            split ?id2
                x
            end ?id2
        split ?id1
            mult ?id3
                ?A&:(numberp ?A)
            split ?id3
                mult ?id4
                    x
                split ?id4
                    x
                end ?id4
            end ?id3
        end ?id1
    $?last)
    =>
    (retract ?old-fact)
    (assert (equation ?first
        add ?id1
            mult ?id3
                ?A
            split ?id3
                mult ?id4
                    x
                split ?id4
                    x
                end ?id4
            end ?id3
        split ?id1
            mult ?id2
                ?B
            split ?id2
                x
            end ?id2
        end ?id1
    ?last))
)

; c + x*b => x*b + c
(defrule flip-c-and-x
    ?old-fact <- (equation 
    $?first
        add ?id1
            ?C&:(numberp ?C)
        split ?id1
            mult ?id2
                ?B&:(numberp ?B)
            split ?id2
                x
            end ?id2
        end ?id1
    $?last)
    =>
    (retract ?old-fact)
    (assert (equation 
    ?first
        add ?id1
            mult ?id2
                ?B
            split ?id2
                x
            end ?id2
        split ?id1
            ?C
        end ?id1
    ?last
)))

; S - C => S + -C
; get rid of subs
(defrule solve-quadratic-equation
    ?old-fact <- (equation 
        add ?id1 
            mult ?id2 
                ?A&:(numberp ?A) 
            split ?id2 
                mult ?id3 
                    x 
                split ?id3 
                    x 
                end ?id3 
            end ?id2 
        split ?id1 
            sub ?id4 
                mult ?id5 
                    ?B&:(numberp ?B) 
                split ?id5 
                    x 
                end ?id5 
            split ?id4 
                ?C&:(numberp ?C) 
            end ?id4 
        end ?id1 
    equal ?rhs&:(numberp ?rhs))
    =>
    (retract ?old-fact)
    (assert (equation 
        add ?id1 
            mult ?id2 
                ?A
            split ?id2 
                mult ?id3 
                    x 
                split ?id3 
                    x 
                end ?id3 
            end ?id2 
        split ?id1 
            add ?id4 
                mult ?id5 
                    ?B
                split ?id5 
                    x 
                end ?id5 
            split ?id4 
                (- 0 ?C)
            end ?id4 
        end ?id1 
    equal ?rhs)))
)
;standardize association of terms
; x*x*a + x*b - c => (x*x*a + x*b) + -c
(defrule standardize-quadratic-equation-c2
    ?old-fact <- (
    equation
        sub ?id1
            add ?id4
                mult ?id2
                    ?A&:(numberp ?A)
                split ?id2
                    mult ?id3
                        x
                    split ?id3
                        x
                    end ?id3
                end ?id2
            split ?id4
                mult ?id2
                    ?B&:(numberp ?B)
                split ?id2
                    x
                end ?id2
            end ?id4
        split ?id1
            ?C&:(numberp ?C)
        end ?id1
    equal ?rhs_num&:(numberp ?rhs_num)
    )
    =>
    (retract ?old-fact)
    (assert (equation
        add ?id1
            add ?id4
                mult ?id2
                    ?A
                split ?id2
                    mult ?id3
                        x
                    split ?id3
                        x
                    end ?id3
                end ?id2
            split ?id4
                mult ?id2
                    ?B
                split ?id2
                    x
                end ?id2
            end ?id4
        split ?id1
            (- 0 ?C)
        end ?id1
    equal ?rhs_num))
)

; S - x*x*a => S + x*x*(-a)
; get rid of subs
;(defrule replace-sub-with-add-x2
;    ?old-fact <- (equation 
;    $?first
;        sub ?id1
;            $?opd1
;        split ?id1
;            mult ?id3
;                ?A&:(numberp ?A)                
;            split ?id3
;                mult ?id4
;                    x
;                split ?id4
;                    x
;                end ?id4
;            end ?id3
;        end ?id1
;    $?last)
;    =>
;    (retract ?old-fact)
;    (assert (equation 
;    ?first
;        add ?id1
;            ?opd1
;        split ?id1
;            mult ?id3
;                (- 0 ?A)
;            split ?id3
;                mult ?id4
;                    x
;                split ?id4
;                    x
;                end ?id4
;            end ?id3
;        end ?id1
;    ?last
;)))

; S - x*b => S + x*(-b)
; get rid of subs
(defrule replace-sub-with-add-x
    ?old-fact <- (equation $?first
        sub ?id1
            $?opd1
        split ?id1
            mult ?id3
                ?B&:(numberp ?B)
            split ?id3
                x
            end ?id3
        end ?id1
    $?last)
    =>
    (retract ?old-fact)
    (assert (equation ?first
        add ?id1
            ?opd1
        split ?id1
            mult ?id3
                (- 0 ?B)
            split ?id3
                x
            end ?id3
        end ?id1
    ?last)))

; x*b => b*x
(defrule flip-x
    ?old-fact <- (equation $?first
        mult ?id
            x
        split ?id
            ?B&:(numberp ?B)
        end ?id
    $?last)
    =>
    (retract ?old-fact)
    (assert (equation ?first
        mult ?id
            ?B
        split ?id
            x
        end ?id
    ?last)))

; x*x*a => a*x*x
; get rid of subs
(defrule flip-x2
    ?old-fact <- (equation 
    $?first
        mult ?id
            mult ?id2
                x
            split ?id2
                x
            end ?id2
        split ?id
            ?A&:(numberp ?A)
        end ?id
    $?last)
    =>
    (retract ?old-fact)
    (assert (equation 
    ?first
        mult ?id
            ?A
        split ?id
            mult ?id2
                x
            split ?id2
                x
            end ?id2
        end ?id
    ?last
)))

; x*x*a => a*x*x
; get rid of subs
(defrule knock-out-zeros-x
    (declare (salience 100))
    ?old-fact <- (equation 
    $?first
        mult ?id
            0
        split ?id
            x
        end ?id
    $?last)
    =>
    (retract ?old-fact)
    (assert (equation 
    $?first
        0
    $?last
)))

; x*x*a => a*x*x
; get rid of subs
(defrule knock-out-zeros-x2
    (declare (salience 99))
    ?old-fact <- (equation 
    $?first
        mult ?id
            0
        split ?id
            mult ?id2
                x
            split ?id2
                x
            end ?id2
        end ?id
    $?last)
    =>
    (retract ?old-fact)
    (assert (equation 
    $?first
        0
    $?last
)))


(defrule Associative_quadratic_combine_num_x
    ; 2a. (F[x] +- Bx) +- Cx => F[x] + ( (0+-Bx) +- Cx)
    ?old-fact <- (equation $?first 
        ?operator&:(lexemep ?operator) ?id 
            ?operator2&:(lexemep ?operator2) ?id2
                $?F_x
            split ?id2
                mult ?id3
                    ?num_B&:(numberp ?num_B)
                split ?id3
                    x
                end ?id3
            end ?id2
        split ?id 
            mult ?id4
                ?num_C&:(numberp ?num_C)
            split ?id4
                x
            end ?id4
        end ?id
    $?last)
    (test (or 
        (= (str-compare ?operator add) 0)
        (= (str-compare ?operator sub) 0)
    ))
    (test (or 
        (= (str-compare ?operator2 add) 0)
        (= (str-compare ?operator2 sub) 0)
    ))
    =>
    (retract ?old-fact)
    (switch ?operator2
        ; 2a. (F[x] + B) +-1 C => F[x] + ( B +-1 C)
        (case add then 
            (assert (equation ?first 
                add ?id2
                    ?F_x
                split ?id2
                    mult ?id3
                        add ?id
                            ?num_B
                        split ?id
                            ?num_C
                        end ?id
                    split ?id3
                        x
                    end ?id3
                end ?id2
            ?last))
        )
        ; 2a. (F[x] - B) +-1 C => F[x] + ( -B +-1 C)
        (case sub then
            (assert (equation ?first 
                add ?id2
                    ?F_x
                split ?id2
                    mult ?id3
                        add ?id
                            (- 0 ?num_B)
                        split ?id
                            ?num_C
                        end ?id
                    split ?id3
                        x
                    end ?id3
                end ?id2
            ?last))
        )
    )
)

(defrule Associative_quadratic_combine_num_x2
    ; 2a. (F[x] +- Bx) +- Cx => F[x] + ( (0+-Bx) +- Cx)
    ?old-fact <- (equation $?first 
        ?operator&:(lexemep ?operator) ?id 
            ?operator2&:(lexemep ?operator2) ?id2
                mult ?id5
                    ?num_B&:(numberp ?num_B)
                split ?id5
                    mult ?id3
                        x
                    split ?id3
                        x
                    end ?id3
                end ?id5
            split ?id2
                $?F_x
            end ?id2
        split ?id 
            mult ?id6
                ?num_C&:(numberp ?num_C)
            split ?id6
                mult ?id4
                    x
                split ?id4
                    x
                end ?id4
            end ?id6
        end ?id
    $?last)
    (test (or 
        (= (str-compare ?operator add) 0)
        (= (str-compare ?operator sub) 0)
    ))
    (test (or 
        (= (str-compare ?operator2 add) 0)
        (= (str-compare ?operator2 sub) 0)
    ))
    =>
    (retract ?old-fact)
    (switch ?operator2
        ; 2a. (Bx^2 + F[x]) +-1 Cx^2 => F[x] + ( B +-1 C)x^2
        (case add then 
            (assert (equation ?first 
                add ?id2
                    ?F_x
                split ?id2
                    mult ?id3
                        ?operator ?id
                            ?num_B
                        split ?id
                            ?num_C
                        end ?id
                    split ?id3
                        mult ?id4
                            x
                        split ?id4
                            x
                        end ?id4
                    end ?id3
                end ?id2
            ?last))
        )
        ; 2a. (Bx^2 - F[x]) +-1 Cx^2=> -F[x] + (B +-1 C)x^2
        (case sub then
            (assert (equation ?first 
                add ?id2
                    sub ?id5
                        0
                    split ?id5
                        ?F_x
                    end ?id5
                split ?id2
                    mult ?id3
                        ?operator ?id
                            ?num_B
                        split ?id
                            ?num_C
                        end ?id
                    split ?id3
                        mult ?id4
                            x
                        split ?id4
                            x
                        end ?id4
                    end ?id3
                end ?id2
            ?last))
        )
    )
)

