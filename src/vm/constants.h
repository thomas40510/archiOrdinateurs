/* Memory storage */
#define MEMSIZE 2048

/* Opcodes */
#define OPCODE_ADD 2
#define OPCODE_ADDI 3
#define OPCODE_SUB 4
#define OPCODE_SUBI 5
#define OPCODE_MUL 6
#define OPCODE_MULI 7
#define OPCODE_DIV 8
#define OPCODE_DIVI 9
#define OPCODE_AND 10
#define OPCODE_ANDI 11
#define OPCODE_OR 12
#define OPCODE_ORI 13
#define OPCODE_XOR 14
#define OPCODE_XORI 15
#define OPCODE_SHL 16
#define OPCODE_SHLI 17
#define OPCODE_SHR 18
#define OPCODE_SHRI 19
#define OPCODE_SLT 20
#define OPCODE_SLTI 21
#define OPCODE_SLE 22
#define OPCODE_SLEI 23
#define OPCODE_SEQ 24
#define OPCODE_SEQI 25
#define OPCODE_LOAD 27
#define OPCODE_STORE 29
#define OPCODE_JMPR 30
#define OPCODE_JMPI 31
#define OPCODE_BRAZ 32
#define OPCODE_BRANZ 33
#define OPCODE_SCALL 34
#define OPCODE_STOP 35

#define TYPE_R 0
#define TYPE_I 1
#define TYPE_JR 2
#define TYPE_JI 3
#define TYPE_B 4
#define TYPE_S 5

/* Registers */
#define NBR_REGS 32

