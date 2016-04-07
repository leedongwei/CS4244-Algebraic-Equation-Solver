(defrule final_result
    ?x <- (equation x equal ?rhs)
    =>
    (printout t crlf "x = " ?rhs crlf)
)

(deffacts initial_equation
    ; 2 = ((4+5) + (x - 3))
    ; (equation 2 equal add 1 add 2 4 split 2 5 end 2 split 1 sub 3 x split 3 3 end 3 end 1)

    ; (4 + 5* x) + (x * 8) * 16 = 2
    (equation
        add 1 
            add 2
                4
            split 2
                mult 3
                    5
                split 3
                    x
                end 3
            end 2
        split 1
            mult 4 
                mult 5
                    x
                split 5
                    8
                end 5
            split 4
                16
            end 4
        end 1
        equal 2
    )

    ; ((x * 8) * 16) + (4 + (5*x)) = 2
    ; (equation
    ;     add 1 
    ;         mult 4
    ;             mult 5
    ;                 x
    ;             split 5
    ;                 8
    ;             end 5
    ;         split 4
    ;             16
    ;         end 4
    ;     split 1
    ;         add 2 
    ;             4
    ;         split 2
    ;             mult 3
    ;                 5
    ;             split 3
    ;                 x
    ;             end 3
    ;         end 2
    ;     end 1
    ;     equal 2
    ; )
)

(defglobal ?*next_id* = 100)