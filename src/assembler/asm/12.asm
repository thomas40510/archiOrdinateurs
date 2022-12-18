    load r2 r0 nb_iter
    add r1 r0 0
loop_for_start:
    sle r4 r1 r2
    braz r4 loop_for_end
    add r20 r0 r1
    scall 1
    add r1 r1 1
    jmp r0 loop_for_start
loop_for_end:
    stop
nb_iter:
    12