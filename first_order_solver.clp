; 1 Commutative_reorder_Fx
; 1a. B +- F[x]  => (+-1)*F[x] + B ; F[x] is anything has x
; 1b. F[x] */ B  => (1*/B) * F[x]
; 1c. F[x] +- Bx => (0+-B)x + F[x]

(defrule Commutative_reorder_Fx_1a
    ?old-fact <- (equation $?first
        ?operator&:(lexemep ?operator) ?id
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
        ?operator&:(lexemep ?operator) ?id 
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

; (defrule Commutative_reorder_Fx_1c
;     ; 1c. F[x] +- Bx => Bx +- F[x]
;     ?old-fact <- (equation $?first 
;         ?operator&:(lexemep ?operator) ?id 
;             $?F_x&:(member$ x ?F_x)
;         split ?id
;             mult ?id2
;                 ?num_B&:(numberp ?num_B)
;             split ?id2
;                 x
;             end ?id2
;         end ?id
;     $?last)
;     (test (or 
;         (= (str-compare ?operator add) 0)
;         (= (str-compare ?operator sub) 0)
;     ))
;     =>
;     (retract ?old-fact)
;     (switch ?operator
;         (case add then 
;             ; 1c. F[x] + Bx => Bx + F[x]
;             (assert (equation ?first 
;                 add ?id
;                     mult ?id2 ?num_B split ?id2 x end ?id2
;                 split ?id 
;                     ?F_x
;                 end ?id ?last)
;             )
;         )(case sub then
;             ; 1c. F[x] - Bx => -Bx + F[x]
;             (assert (equation ?first 
;                 add ?id
;                     mult ?id2 (- 0 ?num_B) split ?id2 x end ?id2
;                 split ?id 
;                     ?F_x
;                 end ?id ?last)
;             )
;         )
;     )
; )

; 2 Associative_combine_num
; 2a. (F[x] +- B) +- C => F[x] + ( (0+-B) +- C)
; 2b. A */ (B */ F[x]) => (A */ B) */ F[x]

(defrule Associative_combine_num_2a
    ; 2a. (F[x] +- B) +- C => F[x] + ( (0+-B) +- C)
    ?old-fact <- (equation $?first 
        ?operator&:(lexemep ?operator) ?id 
            ?operator2&:(lexemep ?operator2) ?id2
                $?F_x&:(member$ x ?F_x)
            split ?id2
                ?num_B&:(numberp ?num_B)
            end ?id2
        split ?id 
            ?num_C&:(numberp ?num_C)
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
    (switch ?operator2
        ; 2a. (F[x] + B) +-1 C => F[x] + ( B +-1 C)
        (case add then 
            (assert (equation ?first 
                add ?id2
                    ?F_x
                split ?id2
                    add ?id
                        ?num_B
                    split ?id
                        ?num_C
                    end ?id
                end ?id2
            ?last))
        )
        ; 2a. (F[x] - B) +-1 C => F[x] + ( -B +-1 C)
        (case sub then
            (assert (equation ?first 
                add ?id2
                    ?F_x
                split ?id2
                    add ?id
                        (- 0 ?num_B)
                    split ?id
                        ?num_C
                    end ?id
                end ?id2
            ?last))
        )
    )

    ; 2a. (F[x] +- B) +- C => F[x] + ( (0+-B) +- C)

)
(defrule Associative_combine_num_2b
    ?old-fact <- (equation $?first 
        ?operator&:(lexemep ?operator) ?id 
            ?num_A&:(numberp ?num_A)
        split ?id 
            ?operator2&:(lexemep ?operator2) ?id2
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

(defrule Associative_combine_x_3a
    ; 3a (B +- F[x]) +- G[x] => B +- ((+-1)F[x]+-G[x])
    ?old-fact <- (equation $?first 
        ?operator&:(lexemep ?operator) ?id 
            ?operator2&:(lexemep ?operator2) ?id2
                ?num_B&:(numberp ?num_B)
            split ?id2
                $?F_x&:(member$ x ?F_x)
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
    ; 3a (B op2 F[x]) op1 G[x] => B + ((+-)F[x] op1 G[x])
    (switch ?operator2
        ; 3a (B + F[x]) op1 G[x] => B + (F[x] op1 G[x])
        (case add then
            (assert (equation $?first 
                add ?id2 
                    ?num_B
                split ?id2 
                    ?operator ?id
                        $?F_x
                    split ?id
                        $?G_x
                    end ?id
                end ?id2
            $?last))
        )
        ; 3a (B - F[x]) +- G[x] => B + (-1*F[x] +- G[x])
        (case sub then
            (assert (equation $?first 
                add ?id2 
                    ?num_B
                split ?id2 
                    ?operator ?id
                        mult ?*next_id* 
                            -1 
                        split ?*next_id*
                            ?F_x 
                        end ?*next_id*
                    split ?id
                        $?G_x
                    end ?id
                end ?id2
            $?last))
            (bind ?*next_id* (+ ?*next_id* 1))
        )
    )
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

(defrule Associative_combine_x_3b
    ; 3b (F[x] +- B) +- G[x] => (F[x] +- G[x]) +- B
    ?old-fact <- (equation $?first 
        ?operator&:(lexemep ?operator) ?id 
            ?operator2&:(lexemep ?operator2) ?id2
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

(defrule Associative_combine_x_3c1
    ; 3c1 Ax +- (Bx +- C) => (Ax +- Bx) +- c
    ?old-fact <- (equation $?first 
        ?operator&:(lexemep ?operator) ?id 
            mult ?id_mult1
                ?num_A&:(numberp ?num_A)
            split ?id_mult1
                x
            end ?id_mult1
        split ?id 
            ?operator2&:(lexemep ?operator2) ?id2
                mult ?id_mult2
                    ?num_B&:(numberp ?num_B)
                split ?id_mult2
                    x
                end ?id_mult2
            split ?id2
                ?num_C&:(numberp ?num_C)
            end ?id2
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
    ; 3c Ax + (Bx +- C) => (Ax + Bx) +- C
    ; 3c Ax - (Bx +- C) => (Ax - Bx) -1*(+-C)
    (switch ?operator
        (case add then 
            (assert 
                (equation ?first 
                    ?operator2 ?id2 
                        add ?id
                            mult ?id_mult1
                                ?num_A
                            split ?id_mult1
                                x
                            end ?id_mult1
                        split ?id
                            mult ?id_mult2
                                ?num_B
                            split ?id_mult2
                                x
                            end ?id_mult2
                        end ?id
                    split ?id2 
                        ?num_C
                    end ?id2
                ?last)
            )
        )(case sub then
            (assert 
                (equation ?first 
                    ?operator2 ?id2 
                        sub ?id
                            mult ?id_mult1
                                ?num_A
                            split ?id_mult1
                                x
                            end ?id_mult1
                        split ?id
                            mult ?id_mult2
                                ?num_B
                            split ?id_mult2
                                x
                            end ?id_mult2
                        end ?id
                    split ?id2 
                        (- 0 ?num_C)
                    end ?id2
                ?last)
            )
        )
    )
)

; 4 Distributive_rule_x_eval_num
; 4a Ax +- Bx => (A +- B) * x
; 4b A * (Bx +- C) => (A * B) * x +- A * C

(defrule Distributive_rule_x_eval_num_4a
    ; 4a Ax +- Bx => (A +- B) * x
    ?old-fact <- (equation $?first 
        ?operator&:(lexemep ?operator) ?id 
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

(defrule Distributive_rule_x_eval_num_4b
    ; 4b A * (Bx +- C) => (A * B) * x +- A * C
    ?old-fact <- (equation $?first 
        mult ?id
            ?num_A&:(numberp ?num_A) 
        split ?id
            ?operator&:(lexemep ?operator) ?id2
                mult ?id3 
                    ?num_B&:(numberp ?num_B) 
                split ?id3 
                    x 
                end ?id3
            split ?id2 
                ?num_C&:(numberp ?num_C)
            end ?id2
        end ?id
    $?last)
    (test (or 
        (= (str-compare ?operator add) 0)
        (= (str-compare ?operator sub) 0)
    ))
    =>
    (retract ?old-fact)
    (assert (equation ?first
            ?operator ?id
                mult ?id2
                    mult ?*next_id*
                        ?num_A
                    split ?*next_id*
                        ?num_B
                    end ?*next_id*
                split ?id2
                    x
                end ?id2
            split ?id
                mult ?id2
                    ?num_A
                split ?id2
                    ?num_C
                end ?id2
            end ?id
        ?last)
    )
    (bind ?*next_id* (+ ?*next_id* 1))
)

; 5 Num_eval_rule
; A+-*/B => C where C=A+-*/B

; 6 Associative_break
; (F[x]+B) + (G[x]+D) = ((F[x]+B)+G[x])+D
