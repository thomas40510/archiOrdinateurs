;=======================================================
;                         chenillard
;=======================================================
;
; while true
;   v=0b1
;   wait_1s()
;   v=0b11
;   wait_1s()
;   v=0b111
;   wait_1s()
;   v=0b1111
;   while v!=0
;     wait_1s()
;     v=v<<1
;   end
; end
;
; func wait_1s()
;   tmp=0
;   while tmp!=50 000 000
;     tmp=tmp+1
;   end
;=========================================================
start_while: add r0,1,r1
      jmp wait_1s,r5      ; lancement de la subroutine
      add r0,3,r1
      jmp wait_1s,r5      ; lancement de la subroutine
      add r0,7,r1
      jmp wait_1s,r5      ; lancement de la subroutine
      add r0,15,r1
loop: seq r1,0,r2         ; r2=1 si r1==0, 0 sinon
      seq r2,r0,r2        ; r2=1 si r2==0, 0 sinon   v!=0 in r2
      braz r2,start_while
      jmp wait_1s,r5      ; lancement de la subroutine
      shl r1,1,r1         ; decalage vers la gauche
      jmp loop,r0
      jmp start_while,r0
;
; procedure de consommation du temps (1 seconde) :
;
wait_1s: add r0,0,r3          ; r3 is tmp
test_loop: seq r3,5,r4          ; r3 = 1 seconde ? si oui r4=1
      branz r4,fin_wait    ; si r4=1, jmp to fin_wait
      add r3,1,r3          ; sinon increment
      jmp test_loop,r0     ; et on poursuit la boucle
fin_wait: jmp r5,r0            ; retour de fonction
