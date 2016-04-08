; 1 Commutative_reorder_Fx
; 1a. B +- F[x]  => (+-1)*F[x] + B ; F[x] is anything has x
; 1b. F[x] */ B  => (1*/B) * F[x]
; 1c. F[x] +- Bx => Bx +- F[x] ; F[x]=Ax+C

(defrule Commutative_reorder_Fx_1a
    ?old-fact <- (equation $?first
        ?operator ?id
            ?num&:(numberp ?num)
        split ?id
            $?F_x&:(member$ x ?F_x)
        end ?id
    $?last)
    (test (or 
        (= (str-compare ?operator add) 0)
        (= (str-compare ?operator sub) 0)
    ))
    =>
    (retract ?old-fact)
    (switch ?operator
        (case add then 
            ; num + F[x] = F[x] + num
            (assert (equation $?first add ?id ?F_x split ?id ?num end ?id $?last))
        )(case sub then
            ; num - F[x] = -1 * F[x] + num
            (assert (equation $?first 
                add ?id 
                    mult ?*next_id* 
                        -1 
                    split ?*next_id*
                        ?F_x 
                    end ?*next_id*
                split ?id 
                    ?num 
                end ?id $?last))
            (bind ?*next_id* (+ ?*next_id* 1))
        )
    )
)

(defrule Commutative_reorder_Fx_1b
    ?old-fact <- (equation $?first 
        ?operator ?id 
            $?F_x&:(member$ x ?F_x)
        split ?id 
            ?num&:(numberp ?num)
        end ?id
    $?last)
    (test (or 
        (= (str-compare ?operator mult) 0)
        (= (str-compare ?operator div) 0)
    ))
    =>
    (retract ?old-fact)
    (if (= ?num 0) then
        (switch ?operator
            (case mult then 
                (assert (equation ?first ?last))
            )(case div then
                (assert (equation x equal undefined))
            )
        )
    else
        (switch ?operator
            (case mult then 
                ; F[x] * B = B * F[x]
                (assert (equation ?first mult ?id ?num split ?id ?F_x end ?id ?last))
            )(case div then
                ; F[x] / B = (1/B) * F[x] ; TODO: not calc div here, keep original format
                (assert (equation ?first mult ?id (/ 1 ?num) split ?id ?F_x end ?id ?last))
            )
        )
    )
)

; 2 Associative_combine_num
; 2a. (F[x] +- B) +- C => F[x] + ( (0+-B) +- C)
; 2b. A */ (B */ F[x]) => (A */ B) */ F[x]

(defrule Associative_combine_num_2b
    ?old-fact <- (equation $?first 
        ?operator ?id 
            ?num_A&:(numberp ?num_A)
        split ?id 
            ?operator2 ?id2
                ?num_B&:(numberp ?num_B)
            split ?id2
                $?F_x&:(member$ x ?F_x)
            end ?id2
        end ?id
    $?last)
    (test (or 
        (= (str-compare ?operator mult) 0)
        (= (str-compare ?operator div) 0)
    ))
    (test (or 
        (= (str-compare ?operator2 mult) 0)
        (= (str-compare ?operator2 div) 0)
    ))
    => 
    (retract ?old-fact)
    (if (= ?num_B 0) then
        (switch ?operator
            (case mult then 
                (assert (equation ?first ?last))
            )(case div then
                (assert (equation x equal undefined))
            )
        )
    else
        (switch ?operator
            (case mult then 
                ; A * (B */ F[x]) => (A * B) */ F[x]
                (assert (equation ?first ?operator2 ?id2 (* ?num_A ?num_B) split ?id2 ?F_x end ?id2 ?last))
            )(case div then
                ; A / (B * F[x]) => (A / B) / F[x]
                ; A / (B / F[x]) => (A / B) * F[x]
                (switch ?operator2
                    (case mult then
                        (assert (equation ?first div ?id2 (/ ?num_A ?num_B) split ?id2 ?F_x end ?id2 ?last))
                    )(case div then
                        (assert (equation ?first mult ?id2 (/ ?num_A ?num_B) split ?id2 ?F_x end ?id2 ?last))
                    )
                )
            )
        )
    )
)

; 3 Associative_combine_x
; 3a (B +- F[x]) +- G[x] => B +- ((+-1)F[x]+-G[x])
; 3b (F[x] +- B) +- G[x] => (F[x] +- G[x]) +- B
; 3c F[x] +- (G[x] +- B) => (F[x] +- G[x]) +- B
; 3d F[x] */ (G[x] */ B) => (F[x] */ G[x]) */ B


(defrule Associative_combine_x_3b
    ; 3b (F[x] +- B) +- G[x] => (F[x] +- G[x]) +- B
    ?old-fact <- (equation $?first 
        ?operator ?id 
            ?operator2 ?id2
                $?F_x&:(member$ x ?F_x)
            split ?id2
                ?num_B&:(numberp ?num_B)
            end ?id2
        split ?id 
            $?G_x&:(member$ x ?G_x)
        end ?id
    $?last)
    (test (or 
        (= (str-compare ?operator add) 0)
        (= (str-compare ?operator sub) 0)
    ))
    (test (or 
        (= (str-compare ?operator2 add) 0)
        (= (str-compare ?operator2 sub) 0)
    ))
    => 
    (retract ?old-fact)
    ; 3b (F[x] op2 B) op1 G[x] => (F[x] op1 G[x]) op2 B
    (assert (equation 
        $?first 
            ?operator2 ?id2
                ?operator ?id 
                    $?F_x
                split ?id 
                    $?G_x
                end ?id
            split ?id2
                ?num_B
            end ?id2
        $?last)
    )
)

; 4 Distributive_rule_x_eval_num
; 4a Ax +- Bx => (A +- B) * x
; 4b A * (Bx +- C) => (A * B) * x +- A * C


(defrule Distributive_rule_x_eval_num_4a
    ; 4a Ax +- Bx => (A +- B) * x
    ?old-fact <- (equation $?first 
        ?operator ?id 
            mult ?id2
                ?num_A&:(numberp ?num_A) 
            split ?id2 
                x 
            end ?id2
        split ?id
            mult ?id3 
                ?num_B&:(numberp ?num_B) 
            split ?id3 
                x 
            end ?id3
        end ?id
    $?last)
    (test (or 
        (= (str-compare ?operator add) 0)
        (= (str-compare ?operator sub) 0)
    ))
    =>
    (retract ?old-fact)
    (assert (equation ?first
            mult ?id2
                ?operator ?id
                    ?num_A
                split ?id
                    ?num_B
                end ?id
            split ?id2
                x
            end ?id2
        ?last)
    )
)
; 5 Num_eval_rule
; A+-*/B => C where C=A+-*/B

; 6 Associative_break
; (F[x]+B) + (G[x]+D) = ((F[x]+B)+G[x])+D