(defrule final_result
    ?x <- (equation x equal ?rhs)
    =>
    (printout t crlf "x = " ?rhs crlf)
)

(defglobal ?*next_id* = 100)