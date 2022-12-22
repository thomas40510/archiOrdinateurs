    scall 0                  ; input number from user
    add r1 r0 r20            ; r1 = r20 (input from user)
    or r3 r0 -1              ; r3 = -1
    or r4 r0 1               ; r4 = 1
    or r9 r0 0               ; r9 = 0
fibo_start:
    add r5 r3 r4             ; r5 = r4 + r3
    add r20 r5 0             ; r20 = r5
    scall 1                  ; print r20
    add r3 r4 0              ; r3 = r4
    add r4 r5 0              ; r4 = r5
    add r9 r9 1              ; r9 = r9 + 1
    slt r8 r9 r1             ; r8 = r9 < r1
    branz r8 fibo_start      ; if r8 != 0 goto fibo_start
    stop                     ; stop