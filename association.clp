(defrule switch-xa-to-ax
    ; x*a = a*x
    ; x/a = (1/a)*x
    ?old-fact <- (equation $?first 
        ?operator ?id 
            x
        split ?id 
            ?a&:(numberp ?a)
        end ?id
    $?last)
    (test (or 
        (= (str-compare ?operator mult) 0)
        (= (str-compare ?operator div) 0)
    ))
    =>
    (retract ?old-fact)
    (if (= ?a 0) then
        (switch ?operator
            (case mult then 
                (assert (equation ?first ?last))
            )(case div then
                (assert (equation x equal undefined))
            )
        )
    else
        (switch ?operator
            (case mult then 
                (assert (equation ?first mult ?id ?a split ?id x end ?id ?last))
            )(case div then
                (assert (equation ?first mult ?id (/ 1 ?a) split ?id x end ?id ?last))
            )
        )
    )

)

; transforms (a (+-) bx) ==>  ((+-) bx + a)
; transforms (a * (b * x)) ==>  (a*b)x
(defrule switch-bx-to-first
    ?old-fact <- (equation $?first
        ?operator ?id
            ?a&:(numberp ?a)
        split ?id
            mult ?id2 ?b split ?id2 x  end ?id2
        end ?id
    $?last)
    (test (or 
        (= (str-compare ?operator add) 0)
        (= (str-compare ?operator sub) 0)
        (= (str-compare ?operator mult) 0)
    ))
    =>
    (retract ?old-fact)
    (switch ?operator
        (case add then 
            ; a + (b * x) => (b * x) + a
            (assert (equation $?first add ?id mult ?id2 ?b split ?id2 x end ?id2 split ?id ?a end ?id $?last))
        )(case sub then
            ; a - (b * x) => (-b * x) + a
            (assert (equation $?first add ?id mult ?id2 (- 0 ?b) split ?id2 x end ?id2 split ?id ?a end ?id $?last))
        )(case mult then
            ; a * (b * x) => (a*b) * x
            (assert (equation $?first mult ?id2 (* ?a ?b) split ?id2 x end ?id2 $?last))
        )
    )
)

; Association Rule
; transforms (((a [*3] x) [+-2] b) [+-1] (c [*4] x)) ==>  (((a [+-1] c) [*3] x) [+-2] b)
; (ax + b) + cx
(defrule association-rules-add-sub1
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
;; Association for add/sub
;; 3 operands: 2 have x, 1 numbers
; (ax +- b) +- cx => (a +- c) * x +- b
; (b  +- ax) +- cx 
; cx +- (ax +- b)
; cx +- (b +- ax)

;; 3 operands: 1 has x, 2 numbers
; a + (b + cx)
; (b + cx) + a
; (a + b) + cx   ;num evaluation rules
; cx + (a + b)   ;num evaluation rules

;; 3 operands: 3 has x
; ax + (bx + cx)
; (bx + cx) + ax

;; 4 operands: 2 has x
; (ax +- b) +- (cx +- d)
; (b +- ax) +- (cx +- d) ;switch-xa-to-ax rule
; (b +- ax) +- (d +- cx) ;switch-xa-to-ax rule
; (ax +- cx) +- (b +- d) ;num-evaluation rule

;; 4 operands: 3 has x
;  (ax +- bx) +- (cx +-d)  ; num-evaluation, 3 operand rules
;  (ax +- bx) +- (d +- cx) ; num-evaluation, 3 operand rules

;; 4 operands: 1 has x
;  (a +- b) +- (cx +-d)  ; num-evaluation, 3 operand rules


;; Association for add/sub for 4 operands
;; Association for add/sub for 3 operands




;; Association for multiplication
; Rule1: (a * (x * b)) => (a*b) * x
; Rule2: ((b * x) * a) => (a*b) * x
; Case (a * (b * x)) => (a*b) * x (implemented in switch-bx-to-first)
; Case ((x * b) * a) => (a*b) * x --> (converted to rule2 by switch-xa-to-ax)

(defrule association-rules-mult1
    ?old-fact <- (equation $?first
        mult ?id
            ?a&:(numberp ?a)
        split ?id
            mult ?id2 
                x
            split ?id2 
                ?b&:(numberp ?b)
            end ?id2
        end ?id
    $?last)
    =>
    (retract ?old-fact)
    ; a * (x * b) => (a*b) * x
    (assert (equation $?first mult ?id (* ?a ?b) split ?id x end ?id $?last))
)

(defrule association-rules-mult2
    ?old-fact <- (equation $?first
        mult ?id
            mult ?id2 
                ?b&:(numberp ?b)
            split ?id2 
                x
            end ?id2
        split ?id
            ?a&:(numberp ?a)
        end ?id
    $?last)
    =>
    (retract ?old-fact)
    ; a * (x * b) => (a*b) * x
    (assert (equation $?first mult ?id (* ?a ?b) split ?id x end ?id $?last))
)
