(defrule final_result
    ?x <- (equation x equal ?rhs)
    =>
    (printout t crlf "x = " ?rhs crlf)
)

(deffacts initial_equation
    ; 2 = ((4+5) + (x - 3))
    (equation 2 equal add 1 add 2 4 split 2 5 end 2 split 1 sub 3 x split 3 3 end 3 end 1)
)

(defglobal ?*next_id* = 100)