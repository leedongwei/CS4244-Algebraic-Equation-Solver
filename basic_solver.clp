
; add 2 a = a + a
; subl 2 a = a - 2
; subr 2 a = 2 - a
(defrule hi
    ?x <- (goals equal ?rhs ?operator ?operand1 $?rest)
    =>
    (retract ?x)
    (switch ?operator
        (case add then (assert (goals equal (- ?rhs ?operand1) ?rest)))
        (case subl then (assert (goals equal (+ ?rhs ?operand1) ?rest)))
        (case subr then (assert (goals equal (- ?operand1 ?rhs) ?rest)))
        (default (printout t "new operator!" crlf))
    )
)

(defrule final
    ?x <- (goals equal ?rhs x)
    =>
    (printout t "Yeah!" crlf)
    
)

(deffacts init-fact
    (goals equal 2 add 4 subl 3 x)
)