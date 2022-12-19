; This program should print 12 on screen
	add r3 r0 3
	add r4 r0 4
	add r5 r0 0
	add r6 r0 r0
loop_start:
	and r7 r4 1
	shr r4 r4 1
	sub r7 r7 1
	xor r7 r7 -1
	and r7 r3 r7
	shl r3 r3 1
	add r6 r6 r7
	add r5 r5 1
	slt r8 r5 32
	branz r8 loop_start
	add r20 r6 r0
	scall 1
	stop