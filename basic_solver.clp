
; op operand1 operand 2 == normal syntax
; add 2 a = 2 + a
; subl 2 a = a - 2
; subr 2 a = 2 - a

; Testing for number: (numberp <expression>) --> TRUE/FALSE
(defrule operand1-is-a-number
    ?old-fact <- (equation ?rhs equal ?operator ?level ?operand1&:(numberp ?operand1) split ?level $?operand2)
    =>
    (retract ?old-fact)
    (switch ?operator
        (case add then 
            (assert (equation (- ?rhs ?operand1) equal ?operand2))
            (printout t crlf ?rhs " = " ?operand1 " + " ?operand2 crlf)
        )(case subl then 
            (assert (equation (+ ?rhs ?operand1) equal ?operand2))
            (printout t crlf ?rhs " = " ?operand2 " - " ?operand1 crlf)
        )(case subr then 
            (assert (equation (- ?operand1 ?rhs) equal ?operand2))
            (printout t crlf ?rhs " = " ?operand1 " - " ?operand2 crlf)
        )(default (printout t "new operator!" crlf))
    )
)

(defrule final
    ?x <- (equation ?rhs equal x)
    =>
    (printout t crlf "x = " ?rhs crlf)
    
)

(deffacts init-fact
    (equation 2 equal add 1 4 split 1 subl 2 3 split 2 x)
)
