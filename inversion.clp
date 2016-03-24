; Inversion rule 1: RHS is a number, 1st operand on LHS is a number
; num1 [operator] F(x) = rhs_num 
; --> F(x) = rhs_num [inverse_operator] num1
(defrule inversion_rule_1
    ?old-fact <- (equation ?operator ?op_id ?num1&:(numberp ?num1) split ?op_id $?F_x equal ?rhs_num&:(numberp ?rhs_num) )
    =>
    (retract ?old-fact)
    (switch ?operator
        (case add then 
            (assert (equation ?F_x equal (- ?rhs_num ?num1)))
        )(case sub then 
            (assert (equation ?F_x equal (- ?num1 ?rhs_num)))
        )
        (default (printout t "[WARNING] operator not exist!" crlf))
    )
)

; Inversion rule 2: RHS is a number, 2nd operand on LHS is a number
; F(x) [operator] num2 = rhs_num 
; --> F(x) = rhs_num [inverse_operator] num2
(defrule inversion_rule_2
    ?old-fact <- (equation ?operator ?op_id $?F_x split ?op_id ?num2&:(numberp ?num2) equal ?rhs_num&:(numberp ?rhs_num) )
    =>
    (retract ?old-fact)
    (switch ?operator
        (case add then 
            (assert (equation ?F_x equal (- ?rhs_num ?num2)))
        )(case sub then 
            (assert (equation ?F_x equal (+ ?rhs_num ?num2)))
        )
        (default (printout t "[WARNING] operator not exist!" crlf))
    )
)

; Make sure X is always on LHS
; F(x) = G(x) --> F(x) - G(x) = 0
(defrule inversion_rule_3_make_sure_x_on_lhs
    ?old-fact <- (equation $?lhs equal $?rhs&:($member x ?rhs))
    =>
    (retract ?old-fact)
    (assert (equation sub ?*next_id* ?lhs split ?*next_id* ?rhs equal 0))
    (bind ?*next_id* (+ ?*next_id* 1))
)

; Number Evaluation Rule: 
; If there is a operation with both number operand, evaluate and replace the operation as a number
; old_fact = ($?begin num1 operator num2 $?end) 
; if num3 = num1 + num2 --> retract old_fact, assert ($?begin num3 $?end)
(defrule num_eval_rule
    ?old-fact <- (equation $?begin ?operator ?op_id ?num1&:(numberp ?num1)) split ?op_id ?num2&:(numberp ?num2) $?end)
    =>
    (retract ?old-fact)
    (switch ?operator
        (case add then 
            (assert (equation $?begin (+ ?num1 ?num2) $?end))
        )(case sub then 
            (assert (equation $?begin (- ?num1 ?num2) $?end))
        )
        (default 
            (printout t "new operator!" crlf)
        )
    )
)
