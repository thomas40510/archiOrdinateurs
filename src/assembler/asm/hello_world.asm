# print 5 times "Hello, world!"
    add r2 r0 nb_iter      # r2 <= @nb_iter
    load r3 r2 0            # r3 <= mem[r2 + 0]
    add r4 r0 0             # r4 <= 0
loop_for_start:
    slt r5 r4 r3            # r5 <= (r4 < r3) ? 1 : 0
    braz r5 loop_for_end    # if (r5 == 0) {PC <= loop_for_end}
    add r20 r0 my_string   # r20 <= @my_string
    scall 4                 # print string @r20 to stdout
    add r4 r4 1             # r4 <= r4 + 1
    jmp r0 loop_for_start   # PC <= @loop_for_start
loop_for_end:
    stop                    # halt the machine
nb_iter:
    5                       # data: number 5
my_string:
    "Hello, world!\n"       # data: null terminated string