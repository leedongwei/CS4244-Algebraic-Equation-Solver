; add a b = a + b
; sub a b = a - b
; mul a b = a * b

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


;;;;;
;;;;;
;;;;; 
;Simplification rules
;;;;;
;;;;;
;;;;;



;;;;;
; transforms (a (+-) bx) ==>  ((+-) bx + a)
;;;;;

(defrule switch-operands
    ?old-fact <- (equation ?rhs equal $?first ?operator1 ?id ?operand1&:(numberp ?operand1) split ?id mult ?id2 ?coef split ?id2 x $?last)
    =>
    (retract ?old-fact)
    (switch ?operator1
        (case add then 
            (equation ?rhs equal $?first add ?id mult ?id2 ?coef split ?id2 x $?last split ?id ?operand1 $?last))
        (case sub then 
            (equation ?rhs equal $?first add ?id mult ?id2 (- 0 ?coef) split ?id2 x split ?id ?operand1 $?last))
    )
)

;;;;;
; transforms (ax 2(+-) b) 1(+-) cx ==>  (a 1(+-) c) * x 2(+-) b
;;;;;


; Association Rule
; transforms (ax (+-) b) (+-) cx ==>  (a (+-) c) * x + b
(defrule association-rules-add-sub1
    ?old-fact <- (equation ?rhs equal $?first ?operator1 ?id ?operator2 ?id2 mult ?id3 ?coef1 split ?id3 x split ?id2 ?operand2&:(numberp ?operand1) split ?id mult ?id4 ?coef2 split ?id4 x $?last)
    =>
    (retract ?old-fact)
    (switch ?operator1
        (case add then 
            (assert (equation ?rhs equal $?first ?operator2 ?id mult ?id4 (eval (str-cat "(+ " ?coef1 " " ?coef2 ")")) split ?id4 x split ?id ?operand2 $?last)))
        (case sub then 
            (assert (equation ?rhs equal $?first ?operator2 ?id mult ?id4 (eval (str-cat "(- " ?coef1 " " ?coef2 ")")) split ?id4 x split ?id ?operand2 $?last)))
    )

)



;;;;;
; transforms (ax 2(+-) b) 1(+-) c ==>  ax + (2(+-)b 1(+-) c)
;;;;;

(defrule association-rules-add-sub2
    ?old-fact <- (equation ?rhs equal $?first ?operator1 ?id ?operator2 ?id2 mult ?id3 ?coef1 split ?id3 x split ?id2 ?b&:(numberp ?b) split ?id ?c $?last)
    =>
    (retract ?old-fact)
    (switch ?operator2
        (case add then 
            (assert (equation ?rhs equal $?first add ?id mult ?id2 ?coef1 split ?id2 x split ?id ?operator1 ?id3 ?b split ?id3 ?c $?last)))
        (case sub then 
            (assert (equation ?rhs equal $?first add ?id mult ?id2 ?coef1 split ?id2 x split ?id ?operator1 ?id3 (- 0 ?b) split ?id3 ?c $?last)))
    )
)



;;;;;
; transforms (ax 2(+-) b) 1(+-) (cx 3(+-) d) ==> (a 1(+-) c)x 2(+-) b 1(+-) 3(+-) d
;;;;;

;equation ?rhs equal $?first 
;    ?operator1 ?id 
;        ?operator2 ?id2 
;           mult ?id3 
;                ?a
;           split ?id3 
;                x
;        split ?id2 
;            ?b&:(numberp ?b)
;    split ?id
;        ?operator2 ?id4
;            mult ?id5
;                ?c
;            split ?id5
;                x
;        split ?id4
;            ?d&:(numberp ?d) 
;$?last

;==>

;equation ?rhs equal $?first 
;    ?operator1 ?id 
;        ?operator2 ?id2 
;           mult ?id3 
;                ?operator1 ?id4
;                    ?a
;                split ?id4
;                    ?c
;           split ?id3 
;                x
;        split ?id2 
;            ?b
;    split ?id
;        ?operator3 ?id5
;            0
;        split ?id5
;            ?d
;$?last

(defrule association-rules-add-sub-reduce
    ?old-fact <- (equation ?rhs equal $?first ?operator1 ?id ?operator2 ?id2 mult ?id3 ?a split ?id3 x split ?id2 ?b&:(numberp ?b) split ?id ?operator2 ?id4 mult ?id5 ?c split ?id5 x split ?id4 ?d&:(numberp ?d) $?last)
    =>
    (retract ?old-fact)
    (assert (equation ?rhs equal $?first ?operator1 ?id ?operator2 ?id2 mult ?id3 ?operator1 ?id4 ?a split ?id4 ?c split ?id3 x split ?id2 ?b split ?id ?operator3 ?id5 0 split ?id5 ?d $?last))
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
(defglobal ?*next_id* = 100)

