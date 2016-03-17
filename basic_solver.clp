
; add 2 a = a + a
; subl 2 a = a - 2
; subr 2 a = 2 - a

; Testing for number: (numberp <expression>) --> TRUE/FALSE
(defrule operand1-is-a-number
    ?old-fact <- (goals equal ?rhs ?operator ?level ?operand1&:(numberp ?operand1) split ?level $?operand2)
    =>
    (retract ?old-fact)
    (switch ?operator
        (case add then 
            (assert (goals equal (- ?rhs ?operand1) ?operand2))
            (printout t crlf ?rhs " = " ?operand1 " + " ?operand2 crlf)
        )(case subl then 
            (assert (goals equal (+ ?rhs ?operand1) ?operand2))
            (printout t crlf ?rhs " = " ?operand2 " - " ?operand1 crlf)
        )(case subr then 
            (assert (goals equal (- ?operand1 ?rhs) ?operand2))
            (printout t crlf ?rhs " = " ?operand1 " - " ?operand2 crlf)
        )(default (printout t "new operator!" crlf))
    )
)

(defrule association
    ?old-fact <- (goals equal ?rhs ?operator ?level $?operand1 split ?level $?operand2)
    =>
    (retract ?old-fact)
    (assert (goals equal ?rhs ?operator ?level ?operand2 split ?level ?operand1))
)

(defrule final
    ?x <- (goals equal ?rhs x)
    =>
    (printout t crlf "x = " ?rhs crlf)
    
)

(deffacts init-fact
    (goals equal 2 add 1 4 split 1 subl 2 3 split 2 x)
)
