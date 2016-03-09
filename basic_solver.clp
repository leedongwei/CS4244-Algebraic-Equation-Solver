(defrule hi
    ?x <- (goals equal ?rhs add ?operand1 $?rest)
    =>
    (retract ?x)
    (assert (goals equal (- ?rhs ?operand1) ?rest))
)

(defrule final
    ?x <- (goals equal ?rhs x)
    =>
    (printout t "Yeah!" crlf)
    
)

(deffacts init-fact
    (goals equal 5 add 3 x)
)