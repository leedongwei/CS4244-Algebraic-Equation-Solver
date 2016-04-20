(defrule final_result
    ?x <- (equation x equal ?rhs)
    =>
    (retract ?x)
    (printout t crlf "x = " ?rhs crlf)
)

(defrule final_result2
    ?x <- (equation x equal ?rhs1 ?rhs2)
    =>
    (retract ?x)
    (printout t crlf "x = " ?rhs1 ", " ?rhs2 crlf)
)

(defglobal ?*next_id* = 100)