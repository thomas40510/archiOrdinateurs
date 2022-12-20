/** @file vm.c
 * @brief Implementation of a virtual machine.
 * @author Thomas Prévost, CSN 2024 @ ENSTA Bretagne
 * @version 1.0
 * @date 2022
 *
 * This program is an elementary mini-MIPS virtual machine,
 * capable of reading and executing instructions from a binary file.
 */

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>

#include "constants.h" // Definitions of constants

/* Memory */
u_int32_t mem[MEMSIZE];
/* Regs */
int regs[NBR_REGS];
/* Program counter */
int pc = 0;

/*--- Global variables for the execution ---*/
/* Vars */
int instr;
int opcode = 0;  // current opcode

/* Init working registers and values */
int rd = 0;
int rs = 0;
int rs1, rs2 = 0;
int ra = 0;
int addr = 0;
int val = 0;

char *progname;

u_int32_t imm = 0;  // immediate value

int isRunning = 1;  // program runs while this is 1

/*--- The program itself ---*/

/** @brief Read a file into memory
 * @param filename the name of the file to read
 *
 */
void readSource(char *filename) {
    int fd = open(filename, O_RDONLY);
    if (fd < 0) {
        printf("Error: Could not open file %s\n", filename);
        exit(1);
    }
    int i = 0;
    while (read(fd, &mem[i], 4) == 4) {  // read 4 bytes at a time
        i++;
    }
    close(fd);
}

/** @brief Display registers and their values */
void displayRegs(){
    int reg;
    printf("Registers:\n");
    for(reg = 0; reg < NBR_REGS; reg++) {
        printf("r%d: %d ", reg, regs[reg]);
    }
    printf("\n");
}

/** @brief Display the memory */
void displayMem(){
    int i;
    printf("Memory:\n");
    for(i = 0; i < MEMSIZE; i++) {
        printf("%d: %d ", i, mem[i]);
    }
    printf("\n");
}

/**
 * @brief Write a value to a register
 * @param reg Register to be written to
 * @param val Value to be written
 */
void writeReg(int reg, int value){
    regs[reg] = (value == 0) ? 0 : value;
}

/**
 * @brief Decode instructions by type
 * @param type: type of instruction (R, I, JR, JI, B, S)
 */
void decodeInstr(int type) {
    switch (type) {
        case TYPE_R:  /* Registry-type */
            rd = (instr >> 21) & 0x1F;
            rs1 = (instr >> 16) & 0x1F;
            rs2 = (instr >> 11) & 0x1F;
            break;
        case TYPE_I:  /* Immediate-type */
            rd = (instr >> 21) & 0x1F;
            rs = (instr >> 16) & 0x1F;
            imm = instr & 0x0000FFFF;
            if ((imm & 0x00008000) != 0) {
                imm |= 0xFFFF0000;
            }
            break;
        case TYPE_JR:  /* Jump to register */
            rd = (instr >> 21) & 0x1F;
            ra = (instr >> 16) & 0x1F;
            break;
        case TYPE_JI:  /* Jump to immediate */
            rd = (instr >> 21) & 0x1F;
            addr = instr & 0x001FFFFF;
            break;
        case TYPE_B:  /* Branch */
            rs = (instr >> 21) & 0x1F;
            addr = instr & 0x1FFFF;
            break;
        case TYPE_S:  /* Scall */
            val = instr & 0x3FFFFFF;
        default:
            break;
    }
}

/**
 * @brief Execute a given instruction
 * @param opcode Opcode of the instruction
 *
 * Decodes the instruction using appropriate type, then executes it
 * using binary operations or updating programCount.
 */
void execOp(int opcode){
    switch (opcode) {
        /* Add */
        case OPCODE_ADD:
            decodeInstr(TYPE_R);
            writeReg(rd, regs[rs1] + regs[rs2]);
            break;
        case OPCODE_ADDI:
            decodeInstr(TYPE_I);
            writeReg(rd, regs[rs] + imm);
            break;

        /* Subtract */
        case OPCODE_SUB:
            decodeInstr(TYPE_R);
            writeReg(rd, regs[rs1] - regs[rs2]);
            break;
        case OPCODE_SUBI:
            decodeInstr(TYPE_I);
            writeReg(rd, regs[rs] - imm);
            break;

        /* Multiply */
        case OPCODE_MUL:
            decodeInstr(TYPE_R);
            writeReg(rd, regs[rs1] * regs[rs2]);
            break;
        case OPCODE_MULI:
            decodeInstr(TYPE_I);
            writeReg(rd, regs[rs] * imm);
            break;

        /* Divide */
        case OPCODE_DIV:
            decodeInstr(TYPE_R);
            writeReg(rd, regs[rs1] / regs[rs2]);
            break;
        case OPCODE_DIVI:
            decodeInstr(TYPE_I);
            writeReg(rd, regs[rs] / imm);
            break;

        /* And */
        case OPCODE_AND:
            decodeInstr(TYPE_R);
            writeReg(rd, regs[rs1] & regs[rs2]);
            break;
        case OPCODE_ANDI:
            decodeInstr(TYPE_I);
            writeReg(rd, regs[rs] & imm);
            break;

        /* Or */
        case OPCODE_OR:
            decodeInstr(TYPE_R);
            writeReg(rd, regs[rs1] | regs[rs2]);
            break;
        case OPCODE_ORI:
            decodeInstr(TYPE_I);
            writeReg(rd, regs[rs] | imm);
            break;

        /* Xor */
        case OPCODE_XOR:
            decodeInstr(TYPE_R);
            writeReg(rd, regs[rs1] ^ regs[rs2]);
            break;
        case OPCODE_XORI:
            decodeInstr(TYPE_I);
            writeReg(rd, regs[rs] ^ imm);
            break;

        /* Shift-left */
        case OPCODE_SHL:
            decodeInstr(TYPE_R);
            writeReg(rd, regs[rs1] << regs[rs2]);
            break;
        case OPCODE_SHLI:
            decodeInstr(TYPE_I);
            writeReg(rd, regs[rs] << imm);
            break;

        /* Shift-right */
        case OPCODE_SHR:
            decodeInstr(TYPE_R);
            writeReg(rd, regs[rs1] >> regs[rs2]);
            break;
        case OPCODE_SHRI:
            decodeInstr(TYPE_I);
            writeReg(rd, regs[rs] >> imm);
            break;

        /* Less than */
        case OPCODE_SLT:
            decodeInstr(TYPE_R);
            writeReg(rd, regs[rs1] < regs[rs2]);
            break;
        case OPCODE_SLTI:
            decodeInstr(TYPE_I);
            writeReg(rd, regs[rs] < imm);
            break;

        /* Less than or equals */
        case OPCODE_SLE:
            decodeInstr(TYPE_R);
            writeReg(rd, regs[rs1] <= regs[rs2]);
            break;
        case OPCODE_SLEI:
            decodeInstr(TYPE_I);
            writeReg(rd, regs[rs] <= imm);
            break;

        /* Equals */
        case OPCODE_SEQ:
            decodeInstr(TYPE_R);
            writeReg(rd, regs[rs1] == regs[rs2]);
            break;
        case OPCODE_SEQI:
            decodeInstr(TYPE_I);
            writeReg(rd, regs[rs] == imm);
            break;

        /* Load */
        case OPCODE_LOAD:
            decodeInstr(TYPE_I);
            if (rs + imm < MEMSIZE) {
                writeReg(rd, mem[regs[rs] + imm]);
            } else {
                printf("Error: Memory address out of bounds\n");
                exit(1);
            }
            break;

        /* Store */
        case OPCODE_STORE:
            decodeInstr(TYPE_I);
            if (rs + imm < MEMSIZE || rs + imm > 0) {
                /* Only store if address is in bounds */
                mem[regs[rs] + imm] = regs[rd];
            } else {
                printf("Error: Memory address out of bounds\n");
                exit(1);
            }
            break;

        /* Jump */
        case OPCODE_JMPR:  // Jump to register
            decodeInstr(TYPE_JR);
            writeReg(rd, pc);
            pc = regs[ra];
            break;
        case OPCODE_JMPI:  // Jump to immediate (label)
            decodeInstr(TYPE_JI);
            writeReg(rd, pc);
            pc = addr;
            break;

        /* Branch */
        case OPCODE_BRAZ:  // Branch if zero
            decodeInstr(TYPE_B);
            if (regs[rs] == 0) {
                pc = addr;
            }
            break;
        case OPCODE_BRANZ:  // Branch if not zero
            decodeInstr(TYPE_B);
            if (regs[rs] != 0) {
                pc = addr;
            }
            break;

        /* System call */
        case OPCODE_SCALL:
            decodeInstr(TYPE_S);
            int usrInput;
            switch (val) {
                case 0:  // user input
                    printf("Please enter an integer: ");
                    scanf("%d", &usrInput);
                    writeReg(20, usrInput);
                    break;
                case 1:
                    printf("[%s // Out]: %d\n", progname, regs[20]);
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
            break;

        /* Stop */
        case 0:  // ensure compatibility with other assemblers
        case OPCODE_STOP:  // opcode as defined in assembler
            isRunning = 0;
            break;
        default:
            printf("Error: Invalid opcode %d\n", opcode);
            isRunning = 0;
            break;
    }
}

/**
 * @brief Executes program
 *
 * Instructions are read from memory and executed until the program stops, or an error is encountered
 */
void exec(){
    printf("=== BEGINNING EXECUTION. BINARY IS %s ===\n", progname);
    while (isRunning) {
        instr = mem[pc++];
        opcode = (instr >> 26) & 0x3F;
        execOp(opcode);
    }
    printf("=== END OF PROGRAM ===\n");
    printf("Last output value: %d\n", regs[20]);
}

/** @brief Main function
 *
 * @param argc Number of arguments
 * @param argv Array of arguments
 * @return 1 if error, 0 if success
 *
 * To run, provide the name of the binary file to be run as an argument
 * ./vm <filename>
 */
int main(int argc, char **argv) {
    if (argc < 2) {
        printf("Error: No input file specified\n");
        printf("Usage: %s <input file>\n", argv[0]);
        return EXIT_FAILURE;
    }
    char *filename = argv[1];
    progname = filename;
    readSource(filename);
    exec();

    return EXIT_SUCCESS;
}