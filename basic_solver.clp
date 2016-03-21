; add 2 a = 2 + a
; subl 2 a = a - 2
; subr 2 a = 2 - a

; Inversion rule 1: RHS is a number, 1st operand on LHS is a number
; num1 [operator] F(x) = rhs_num 
; --> F(x) = rhs_num [inverse_operator] num1
(defrule inversion_rule_1
    ?old-fact <- (equation ?operator ?level ?operand1&:(numberp ?operand1) split ?level $?operand2 equal ?rhs&:(numberp ?rhs))
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

; Inversion rule 2: RHS is a number, 2nd operand on LHS is a number
; F(x) [operator] num2 = rhs_num 
; --> F(x) = rhs_num [inverse_operator] num2


; Inversion rule 3: If there are x on RHS, move them to LHS
; F(x) = G(x) --> F(x) - G(x) = 0

(defrule final
    ?x <- (equation ?rhs equal x)
    =>
    (printout t crlf "x = " ?rhs crlf)
    
)

(deffacts init-fact
    (equation 2 equal add 1 4 split 1 subl 2 3 split 2 x)
)
