; add 2 a = 2 + a
; subl 2 a = a - 2
; subr 2 a = 2 - a

; Inversion rule 1: RHS is a number, 1st operand on LHS is a number
; num1 [operator] F(x) = rhs_num 
; --> F(x) = rhs_num [inverse_operator] num1
(defrule inversion_rule_1
    ?old-fact <- (equation ?rhs&:(numberp ?rhs) equal ?operator ?level ?operand1&:(numberp ?operand1) split ?level $?operand2 )
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
(defrule inversion_rule_2
    ?old-fact <- (equation ?rhs&:(numberp ?rhs) equal ?operator ?level $?operand1 split ?level ?operand2&:(numberp ?operand2))
    => 
    (retract ?old-fact)
    (switch ?operator
        (case add then 
            (assert (equation (- ?rhs ?operand2) equal ?operand1))
            (printout t crlf ?rhs " = " ?operand2 " + " ?operand1 crlf)
        )(case subl then 
            (assert (equation (+ ?rhs ?operand2) equal ?operand1))
            (printout t crlf ?rhs " = " ?operand1 " - " ?operand2 crlf)
        )(case subr then 
            (assert (equation (- ?operand2 ?rhs) equal ?operand1))
            (printout t crlf ?rhs " = " ?operand2 " - " ?operand1 crlf)
        )(default (printout t "new operator!" crlf))
    )
)

; Inversion rule 3: If there are x on RHS, move them to LHS
; F(x) = G(x) --> F(x) - G(x) = 0
(defrule inversion_rule_3
    ?old-fact <- (equation ?rhs equal ?operator ?level ?operand1&:(numberp ?operand1) split ?level $?operand2)
    =>
    (retract ?old-fact)
    (switch ?operator
        (case add then 
            (assert (equation (- ?operand2 ?rhs) equal (- 0 ?operand1)))
            (printout t crlf ?rhs " = " ?operand1 " + " ?operand2 crlf)
        )(case subl then 
            (assert (equation (- ?rhs ?operand2) equal ?operand1))
            (printout t crlf ?rhs " = " ?operand1 " - " ?operand2 crlf)
        )(case subr then 
            (assert (equation (- ?operand2 ?rhs) equal (- 0 ?operand1)))
            (printout t crlf ?rhs " = " ?operand1 " - " ?operand2 crlf)
        )(default (printout t "new operator!" crlf))
    )
)

; Number Evaluation Rule: 
; If there is a operation with both number operand, evaluate and replace the operation as a number
; old_fact = ($?begin num1 operator num2 $?end) 
; if num3 = num1 + num2 --> retract old_fact, assert ($?begin num3 $?end)
(defrule num_eval_rule
    ?old-fact <- (equation ?rhs equal ?operator ?level ?operand1&:(numberp ?operand1) split ?level $?operand2 )
    (test (and (numberp ?operand1) (numberp ?operand2)))
    =>
    (retract ?old-fact)
    (assert (equation ?rhs equal (+ ?operand1 ?operand2)))
)


; Association Rule
; transforms (ax (+-) b) (+-) cx ==>  (a (+-) c) * x + b
(defrule association-rules-add-sub
    ?old-fact <- (equation ?rhs equal $?first ?operator1 ?id ?operator2 ?id2 mult ?id3 ?coef1 split ?id3 x split ?id2 ?operand2&:(numberp ?operand1) split ?id3 mult ?id4 ?coef2 split ?id4 x $?last)
    =>
    (retract ?old-fact)
    (assert (equation ?rhs equal $?first ?operator2 ?id mult ?id2 ((eval ?operator1) ?coef1 ?coef2) split ?id2 x split ?id ?operand2 $?last))
)

; transforms (b (+-) ax) (+-) cx ==> ( ( (+-)a ) * x + b ) (+-) c * x
(defrule association-rules-add-sub-2
    ?old-fact <- (equation ?rhs equal $?first ?operator1 ?id ?operator2 ?id2 ?operand1&:(numberp ?operand1) split ?id2 mult ?id3 ?coef1 split ?id3 x split ?id3 mult ?id4 ?coef2 split ?id4 x $?last)
    =>
    (retract ?old-fact)
    (switch ?operator
        (case add then 
            (assert (equation ?rhs equal $?first ?operator1 ?id add ?id2 mult ?id4 ?coef1 split ?id4 x split ?id2 ?operand1 split ?id3 mult ?id4 ?coef2 split ?id4 x $?last))
        )(case sub then 
            (assert (equation ?rhs equal $?first ?operator1 ?id add ?id2 mult ?id4 (- 0 ?coef1) split ?id4 x split ?id2 ?operand1 split ?id3 mult ?id4 ?coef2 split ?id4 x $?last))
        )(default (printout t "new operator!" crlf))
    )
)

(defrule association-rules
    ?old-fact <- (equation ?rhs equal $?first ?operator ?id ?operator2 ?id2 ?operand1&:(str-index "x" ?operand1) split ?id2 ?operand2&:(numberp ?operand1) split ?id ?operator2 ?id3 ?operand3&:(str-index "x" ?operand3) split ?id3 ?operand4&:(numberp ?operand1) $?last)
    =>
    (retract ?old-fact)
    (assert (equation ?rhs equal $?first add ?id ?operator1 ?id2 ?operand1 split ?id2 ?operand3 split ?id ?operator3 ?id3 ((eval ?operator2) 0 ?operand2) split ?id3 ?operand4 $?last))

)

(defrule final
    ?x <- (equation ?rhs equal x)
    =>
    (printout t crlf "x = " ?rhs crlf)
    
)

(deffacts init-fact
    (equation 2 equal add 1 4 split 1 subl 2 3 split 2 x)
)
