
; op operand1 operand 2 == normal syntax
; add 2 a = 2 + a
; subl 2 a = a - 2
; subr 2 a = 2 - a
; mul 2 3 = 2 * 3

; Testing for number: (numberp <expression>) --> TRUE/FALSE
(defrule operand1-is-a-number
    ?old-fact <- (equation ?rhs equal ?operator ?id ?operand1&:(numberp ?operand1) split ?id $?operand2)
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

(defrule association-rules-add-sub
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

(defrule association-rules-add-sub
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
