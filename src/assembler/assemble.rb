require 'colorize' # (sudo) gem install colorize
require 'optparse'

# Implements an assembler for the mini-MIPS project.
# It takes a file containing assembly code and produces a binary file
# Usage: ruby assemble.rb <input file> <output file>
class Assembler
  # initialize the assembler with opcodes, regexes and class vars
  def initialize(file, output = 'out/output.bin')
    @opcodes = { # opcodes
                 'add' => 2, 'addi' => 3,
                 'sub' => 4, 'subi' => 5,
                 'mul' => 6, 'muli' => 7,
                 'div' => 8, 'divi' => 9,
                 'and' => 10, 'andi' => 11,
                 'or' => 12, 'ori' => 13,
                 'xor' => 14, 'xori' => 15,
                 'shl' => 16, 'shli' => 17,
                 'shr' => 18, 'shri' => 19,
                 'slt' => 20, 'slti' => 21,
                 'sle' => 22, 'slei' => 23,
                 'seq' => 24, 'seqi' => 25,
                 'load' => 27,
                 'store' => 29,
                 'jmp' => 30, 'jmpi' => 31,
                 'braz' => 32, 'branz' => 33,
                 'scall' => 34,
                 'stop' => 35
    }
    # 32 registers
    @regs = %w[r0 r1 r2 r3 r4 r5 r6 r7 r8 r9
               r10 r11 r12 r13 r14 r15 r16 r17 r18 r19
               r20 r21 r22 r23 r24 r25 r26 r27 r28 r29
               r30 r31]
    @regexes = {
      'comment' => /;.*/
    }

    @source = file # source file
    @content = _readfile # content of the source file
    @operations = [] # list of operations (and their parameters)
    @labels = {} # labels of the program
    @output = output # output file
    @assembled = '' # assembled binary
  end

  # Read the file line by line and return it as an array
  # @return [Array] the content of the file
  def _readfile
    res = []
    content = File.open(@source, 'r').readlines
    content.each do |line| # line-by-line, without comment-lines
      line.gsub!(@regexes['comment'], '')
      line.strip!
      res << line unless line.empty?
    end
    res
  end

  # Extract labels from asm code
  def _readlabels
    puts '=========== Reading  labels ==========='.light_blue
    labels = {}
    @content.each do |line|
      next unless line.include?(':') # all labels are defined as 'label:'

      label, newline = line.split(':')
      labels[label] = @content.index(line) # gets corresponding line number and store it
      if newline.nil? || newline.empty? # if the line is empty, let label point to next line
        @content.delete(line)
      else
        newline.strip!
        @content[@content.index(line)] = newline
      end
      puts "[Log/I]: Label #{label} found at line #{labels[label]}"
    end
    puts '========= Done reading labels ========='.light_blue
    labels
  end

  # Extract operations and their parameters from asm code
  # @return [Array] list of operations and their parameters
  def _readops
    puts '=========== Reading operations ==========='.green
    ops = []
    @content.each do |line|
      next if line[0] == ';' || line.nil? || line.empty?

      line = line.split(';', 2)[0] # remove comments
      next if line.nil? || line.empty?

      op, params = line.split(' ', 2) # split on first space
      if @opcodes.include?(op) # if the operation is valid
        ops << [op, params]
        puts "[Log/I]: Operation #{op} found with params #{params}"
      else
        puts "[Log/E]: Operation #{op} unknown at line #{line}"
      end
    end
    puts '========= Done reading operations ========='.green
    ops
  end

  # get the address of a register or a label
  # @param [String] reg name of the register, label or value
  # @return [Integer] the address of the register or label, or the value itself
  def _getaddr(reg)
    if @regs.include?(reg) # if it's a register
      @regs.index(reg)
    elsif @labels.include?(reg) # if it's a label
      @labels[reg]
    else # if it's a value
      reg.to_i
    end
  end

  # check if given param is an immediate value
  def _isvalue(reg)
    !@regs.include?(reg) && !@labels.include?(reg)
  end

  # Define binary operations
  # Format op r1, v, r2
  # @param [String] op operation
  # @param [String] params parameters
  # @return [Integer] the binary representation of the operation
  def op_binary(op, params)
    r1, v, r2 = splitparams(params)

    r2, v = v, r2 unless @regs.include?(v) # ensure compatibility among asm writing standards

    if _isvalue(r2) && !@opcodes["#{op}i"].nil? # immediate operation, if possible
      op = @opcodes["#{op}i"] << 26
      r2 = _getaddr(r2) & 0x0000FFFF
    else
      op = @opcodes[op] << 26
      r2 = _getaddr(r2) << 11
    end

    r1 = _getaddr(r1) << 21
    v = _getaddr(v) << 16
    op | r1 | v | r2 # binary representation
  end

  # Define jump operation
  # @param [String] params parameters of the operation
  # @return [Integer] the binary representation of the operation
  def jmp(params)
    ra, rd = splitparams(params)
    rd, ra = ra, rd unless @regs.include?(rd)

    if _isvalue(rd) # immediate
      op = @opcodes['jmpi'] << 26
      rd = _getaddr(rd) & 0x000fffff
    else
      op = @opcodes['jmp'] << 26
      rd = _getaddr(rd) << 16
    end

    ra = _getaddr(ra) << 21

    op | rd | ra
  end

  # Define braz and branz operations
  # @param [String] params parameters of the operation
  # @return [Integer] the binary representation of the operation
  def braz(params, op = 'braz')
    rs, addr = splitparams(params)
    rs, addr = addr, rs unless @regs.include?(rs)
    op = @opcodes[op] << 26
    rs = _getaddr(rs) << 21
    addr = _getaddr(addr) & 0x000fffff
    op | rs | addr
  end

  def branz(params)
    braz(params, 'branz')
  end

  # Define scall operation
  # @param [String] param parameter of the scall
  # @return [Integer] the binary representation of the operation
  def scall(param)
    op = @opcodes['scall'] << 26
    n = _getaddr(param) & 0x03ffffff
    op | n
  end

  # Define stop operation
  # @return [Integer] the binary representation of the operation
  def stop(_params)
    @opcodes['stop'] << 26
  end

  # Split parameters of an operation, identifying the separator
  def splitparams(params)
    sep = params.include?(',') ? ',' : ' '
    params.split(sep)
  end

  # Identifies if an operation is binary
  # @param [String] params parameters of the operation
  # @return [Boolean] true if the operation is binary (3 params), false otherwise
  def _isbinary(params)
    if params.nil? || params.empty?
      false
    else
      splitparams(params).length == 3
    end
  end

  # Convert to hexadecimal
  def bin2hex(bin)
    # convert to hexadecimal
    res = bin.to_s(2).rjust(32, '0').scan(/.{4}/).map { |x| x.to_i(2).to_s(16) }.join
    # reverse bytes : 00 00 00 87 -> 87 00 00 00
    res.scan(/.{2}/).reverse.join
  end

  # Assemble the code (generate binary), operation by operation
  def _assemble
    puts '=========== Assembling ==========='.light_green
    res = []

    @operations.each do |op, params|
      next unless @opcodes.include?(op)

      puts "[Log/I]: Assembling #{op} with #{params}"
      res.append(if _isbinary(params)
                   bin2hex(op_binary(op, params))
                 else
                   bin2hex(send(op, params))
                 end)
    end
    puts '========= Done assembling ========='.light_green
    res
  end

  # Format content to be written in the output file
  def _gencontent
    res = ''
    @assembled.each do |instruction|
      res += instruction
    end
    res
  end

  # Execute the assembler
  # 1. labels, 2. operations, 3. assemble, 4. write to file
  def exec
    @labels = _readlabels
    @operations = _readops
    @assembled = _assemble
    res = _gencontent

    # check if output dir exists
    outdir = File.dirname(@output)
    Dir.mkdir(outdir) unless Dir.exist?(outdir)
    File.open(@output, 'w') do |f|
      # unpack the binary string into an array of 32-bit integers
      # and write it to the file
      f.write([res].pack('H*'))
    end
    puts "[Log/I]: Assembled file saved to #{@output}"
  end
end


# handle command-line params
if ARGV.length != 2
  puts 'Usage: assemble.rb input_file output_file'
  exit(1)
else
  input = ARGV[0]
  output = ARGV[1]
end

# create assembler object and run it
assembler = Assembler.new(input, output)
assembler.exec
