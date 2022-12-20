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
#include <string.h>

#include "constants.h"

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

void decodeInstr(int type) {
    switch (type) {
        case TYPE_R:
            rd = (instr >> 21) & 0x1F;
            rs1 = (instr >> 16) & 0x1F;
            rs2 = (instr >> 11) & 0x1F;
            break;
        case TYPE_I:
            rd = (instr >> 21) & 0x1F;
            rs = (instr >> 16) & 0x1F;
            imm = instr & 0x0000FFFF;
            if ((imm & 0x00008000) != 0) {
                imm |= 0xFFFF0000;
            }
            break;
        case TYPE_JR:
            rd = (instr >> 21) & 0x1F;
            ra = (instr >> 16) & 0x1F;
            break;
        case TYPE_JI:
            rd = (instr >> 21) & 0x1F;
            addr = instr & 0x001FFFFF;
            break;
        case TYPE_B:
            rs = (instr >> 21) & 0x1F;
            addr = instr & 0x1FFFF;
            break;
        case TYPE_S:
            val = instr & 0x3FFFFFF;
        default:
            break;
    }
}

void execOp(int opcode){
    switch (opcode) {
        case OPCODE_ADD:
            decodeInstr(TYPE_R);
            writeReg(rd, regs[rs1] + regs[rs2]);
            break;
        case OPCODE_ADDI:
            decodeInstr(TYPE_I);
            writeReg(rd, regs[rs] + imm);
            break;
        case OPCODE_SUB:
            decodeInstr(TYPE_R);
            writeReg(rd, regs[rs1] - regs[rs2]);
            break;
        case OPCODE_SUBI:
            decodeInstr(TYPE_I);
            writeReg(rd, regs[rs] - imm);
            break;
        case OPCODE_MUL:
            decodeInstr(TYPE_R);
            writeReg(rd, regs[rs1] * regs[rs2]);
            break;
        case OPCODE_MULI:
            decodeInstr(TYPE_I);
            writeReg(rd, regs[rs] * imm);
            break;
        case OPCODE_DIV:
            decodeInstr(TYPE_R);
            writeReg(rd, regs[rs1] / regs[rs2]);
            break;
        case OPCODE_DIVI:
            decodeInstr(TYPE_I);
            writeReg(rd, regs[rs] / imm);
            break;
        case OPCODE_AND:
            decodeInstr(TYPE_R);
            writeReg(rd, regs[rs1] & regs[rs2]);
            break;
        case OPCODE_ANDI:
            decodeInstr(TYPE_I);
            writeReg(rd, regs[rs] & imm);
            break;
        case OPCODE_OR:
            decodeInstr(TYPE_R);
            writeReg(rd, regs[rs1] | regs[rs2]);
            break;
        case OPCODE_ORI:
            decodeInstr(TYPE_I);
            writeReg(rd, regs[rs] | imm);
            break;
        case OPCODE_XOR:
            decodeInstr(TYPE_R);
            writeReg(rd, regs[rs1] ^ regs[rs2]);
            break;
        case OPCODE_XORI:
            decodeInstr(TYPE_I);
            writeReg(rd, regs[rs] ^ imm);
            break;
        case OPCODE_SHL:
            decodeInstr(TYPE_R);
            writeReg(rd, regs[rs1] << regs[rs2]);
            break;
        case OPCODE_SHLI:
            decodeInstr(TYPE_I);
            writeReg(rd, regs[rs] << imm);
            break;
        case OPCODE_SHR:
            decodeInstr(TYPE_R);
            writeReg(rd, regs[rs1] >> regs[rs2]);
            break;
        case OPCODE_SHRI:
            decodeInstr(TYPE_I);
            writeReg(rd, regs[rs] >> imm);
            break;
        case OPCODE_SLT:
            decodeInstr(TYPE_R);
            writeReg(rd, regs[rs1] < regs[rs2]);
            break;
        case OPCODE_SLTI:
            decodeInstr(TYPE_I);
            writeReg(rd, regs[rs] < imm);
            break;
        case OPCODE_SLE:
            decodeInstr(TYPE_R);
            writeReg(rd, regs[rs1] <= regs[rs2]);
            break;
        case OPCODE_SLEI:
            decodeInstr(TYPE_I);
            writeReg(rd, regs[rs] <= imm);
            break;
        case OPCODE_SEQ:
            decodeInstr(TYPE_R);
            writeReg(rd, regs[rs1] == regs[rs2]);
            break;
        case OPCODE_SEQI:
            decodeInstr(TYPE_I);
            writeReg(rd, regs[rs] == imm);
            break;
        case OPCODE_LOAD:
            decodeInstr(TYPE_I);
            if (rs + imm < MEMSIZE) {
                writeReg(rd, mem[regs[rs] + imm]);
            } else {
                printf("Error: Memory address out of bounds\n");
                exit(1);
            }
            break;
        case OPCODE_STORE:
            decodeInstr(TYPE_I);
            if (rs + imm < MEMSIZE || rs + imm > 0) {
                mem[regs[rs] + imm] = regs[rd];
            } else {
                printf("Error: Memory address out of bounds\n");
                exit(1);
            }
            break;
        case OPCODE_JMPR:
            decodeInstr(TYPE_JR);
            writeReg(rd, pc);
            pc = regs[ra];
            break;
        case OPCODE_JMPI:
            decodeInstr(TYPE_JI);
            writeReg(rd, pc);
            pc = addr;
            break;
        case OPCODE_BRAZ:
            decodeInstr(TYPE_B);
            if (regs[rs] == 0) {
                pc = addr;
            }
            break;
        case OPCODE_BRANZ:
            decodeInstr(TYPE_B);
            if (regs[rs] != 0) {
                pc = addr;
            }
            break;
        case OPCODE_SCALL:
            decodeInstr(TYPE_S);
            int usrInput;
            switch (val) {
                case 0:
                    printf("Please enter an integer: ");
                    scanf("%d", &usrInput);
                    writeReg(20, usrInput);
                    break;
                case 1:
                    printf("[Out]: %d\n", regs[20]);
                    break;
                case 2:
                    printf("%d", regs[20]);
                    break;
                case 3:
                    printf("%c", regs[20] & 0x7f);
                    break;
                default:
                    break;
            }
            sleep(1);
            break;
        case 0:
        case OPCODE_STOP:
            isRunning = 0;
            break;
        default:
            printf("Error: Invalid opcode %d\n", opcode);
            isRunning = 0;
            break;
    }
}

void exec(){
    while (isRunning) {
        instr = mem[pc++];
        opcode = (instr >> 26) & 0x3F;
        execOp(opcode);
    }
    printf("=== END OF PROGRAM ===\n");
}


int main(int argc, char **argv) {
    if (argc < 2) {
        printf("Error: No input file specified\n");
        printf("Usage: %s <input file>\n", argv[0]);
        return EXIT_FAILURE;
    }
    char *filename = argv[1];
    readSource(filename);
    exec();

    return EXIT_SUCCESS;
}