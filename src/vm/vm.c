#include <stdio.h>
#include <stdint.h>
#include <signal.h>
/* unix-systems only */
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/termios.h>
#include <sys/mman.h>

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

/* Registers */
#define NBR_REGS 32

/* Memory */
u_int32_t mem[MEMSIZE];
int regs[NBR_REGS];
/* Program counter */
int pc = 0;

/* Vars */
int instr;
int opcode = 0;
int rd = 0;
int rs = 0;
int rs1, rs2 = 0;
int ra = 0;
int addr = 0;
int val = 0;

u_int32_t imm = 0;

int isRunning = 1;

void readSource(char *filename) {
    int fd = open(filename, O_RDONLY);
    if (fd < 0) {
        printf("Error: Could not open file %s\n", filename);
        exit(1);
    }
    int i = 0;
    while (read(fd, &mem[i], 4) == 4) {
        i++;
    }
    close(fd);
}

void displayRegs(){
    int reg;
    printf("Registers:\n");
    for(reg = 0; reg < NBR_REGS; reg++) {
        printf("r%d: %d ", reg, regs[reg]);
    }
    printf("\n");
}

void displayMem(){
    int i;
    printf("Memory:\n");
    for(i = 0; i < MEMSIZE; i++) {
        printf("%d: %d ", i, mem[i]);
    }
    printf("\n");
}

void writeReg(int reg, int value){
    regs[reg] = (value == 0) ? 0 : value;
}

void decodeInstr(char type) {
    switch (type) {
        case 'r':
            rd = (instr >> 21) & 0x1F;
            rs1 = (instr >> 16) & 0x1F;
            rs2 = (instr >> 11) & 0x1F;
            break;
        case 'i':
            rd = (instr >> 21) & 0x1F;
            rs = (instr >> 16) & 0x1F;
            imm = instr & 0x0000FFFF;
            if ((imm & 0x00008000) != 0) {
                imm |= 0xFFFF0000;
            }
            break;
        case 'ji':
            rd = (instr >> 21) & 0x1F;
            addr = instr & 0x001FFFFF;
            break;
        case 'jr':
            rd = (instr >> 21) & 0x1F;
            ra = (instr >> 16) & 0x1F;
            break;
        case 'b':
            rs = (instr >> 16) & 0x1F;
            addr = instr & 0x1FFFF;
            break;
        case 's':
            val = (instr >> 21) & 0x1F;
    }
}


int main(int argc, char **argv){
    printf("Hello world");
    exit(0);
}