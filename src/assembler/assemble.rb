require 'colorize'
require 'bindata'
# class Assembler
# Opens an asm file and extracts the instructions to binary
# instantiate with Assembler.new('path_to_file', 'path_to_output_file')
#
class Assembler
  def initialize(file, output = 'out/output.bin')
    @opcodes = {
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
    @regs = %w[r0 r1 r2 r3 r4 r5 r6 r7 r8 r9
               r10 r11 r12 r13 r14 r15 r16 r17 r18 r19
               r20 r21 r22 r23 r24 r25 r26 r27 r28 r29
               r30 r31]
    @regexes = {
      'stop' => /stop/,
      'add' => /add\s(r[0-9]|r[0-9][0-9]),((r|)[0-9]|r[0-9][0-9]),(r[0-9]|r[0-9][0-9])/,
      'sub' => /sub\s(r[0-9]|r[0-9][0-9]),((r|)[0-9]|r[0-9][0-9]),(r[0-9]|r[0-9][0-9])/,
      'mul' => /mul\s(r[0-9]|r[0-9][0-9]),((r|)[0-9]|r[0-9][0-9]),(r[0-9]|r[0-9][0-9])/,
      'div' => /div\s(r[0-9]|r[0-9][0-9]),((r|)[0-9]|r[0-9][0-9]),(r[0-9]|r[0-9][0-9])/,
      'and' => /and\s(r[0-9]|r[0-9][0-9]),(r[0-9]|r[0-9][0-9]),(r[0-9]|r[0-9][0-9])/,
      'or' => /or\s(r[0-9]|r[0-9][0-9]),(r[0-9]|r[0-9][0-9]),(r[0-9]|r[0-9][0-9])/,
      'xor' => /xor\s(r[0-9]|r[0-9][0-9]),(r[0-9]|r[0-9][0-9]),(r[0-9]|r[0-9][0-9])/,
      'shl' => /shl\s(r[0-9]|r[0-9][0-9]),(r[0-9]|r[0-9][0-9]),(r[0-9]|r[0-9][0-9])/,
      'shr' => /shr\s(r[0-9]|r[0-9][0-9]),(r[0-9]|r[0-9][0-9]),(r[0-9]|r[0-9][0-9])/,
      'slt' => /slt\s(r[0-9]|r[0-9][0-9]),(r[0-9]|r[0-9][0-9]),(r[0-9]|r[0-9][0-9])/,
      'sle' => /sle\s(r[0-9]|r[0-9][0-9]),(r[0-9]|r[0-9][0-9]),(r[0-9]|r[0-9][0-9])/,
      'seq' => /seq\s(r[0-9]|r[0-9][0-9]),(r[0-9]|r[0-9][0-9]),(r[0-9]|r[0-9][0-9])/,
      'load' => /load\s(r[0-9]|r[0-9][0-9]),(r[0-9]|r[0-9][0-9]),([0-9]|r[0-9][0-9])/,
      'store' => /store\s(r[0-9]|r[0-9][0-9]),(r[0-9]|r[0-9][0-9]),([0-9]|r[0-9][0-9])/,
      'jmp' => /jmp\s(\w*),(r[0-9]|r[0-9][0-9])/,
      'braz' => /braz\s(r[0-9]|r[0-9][0-9]),(\w*)/,
      'branz' => /branz\s(r[0-9]|r[0-9][0-9]),([0-9]|r[0-9][0-9])/,
      'scall' => /scall\s([0-9]|r[0-9][0-9])/,
      'label' => /([a-z]+):/,
      'comment' => /;.*/
    }

    @source = file
    @content = _readfile
    @operations = []
    @labels = {}
    @output = output
    @assembled = ''
  end

  def _readfile
    res = []
    content = File.open(@source, 'r').readlines
    content.each do |line|
      line.gsub!(@regexes['comment'], '')
      line.strip!
      res << line unless line.empty?
    end
    res
  end

  def _readlabels
    puts '=========== Reading  labels ==========='.light_blue
    labels = {}
    @content.each do |line|
      next unless line.include?(':')

      label, newline = line.split(':')
      labels[label] = @content.index(line)
      if newline.nil? || newline.empty?
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

  # def _readops
  #   ops = []
  #   @content.each do |line|
  #     next if line[0] == ';' || line.nil?
  #
  #     line = line.split(': ')[1] if line.include?(':')
  #     next if line.nil?
  #
  #     line = line.split(';')[0] if line.include?(';')
  #     @regexes.each do |op, regex|
  #       next unless line.match(regex)
  #
  #       params = line.split(' ')[1]
  #       ops << [op.to_s, params.to_s]
  #       puts "[Log/I]: Operation #{op} found with params #{params}"
  #     end
  #   end
  #   ops
  # end
  def _readops
    puts '=========== Reading operations ==========='.green
    ops = []
    @content.each do |line|
      next if line[0] == ';' || line.nil? || line.empty?

      line = line.split(';', 2)[0]
      next if line.nil? || line.empty?

      op, params = line.split(' ', 2)
      if @opcodes.include?(op)
        ops << [op, params]
        puts "[Log/I]: Operation #{op} found with params #{params}"
      else
        puts "[Log/E]: Operation #{op} unknown at line #{line}"
      end
    end
    puts '========= Done reading operations ========='.green
    ops
  end

  #   def op_ternary(op, params)
  #     r1, v, r2 = params.split(',')
  #     raise "Error in #{op} #{params}" unless @regs.include?(r1) && @regs.include?(r2)
  #
  #     res = @opcodes[op] << 27
  #     r1 = @regs.index(r1)
  #     r2 = @regs.index(r2)
  #     res += r1 << 22
  #     if @regs.include?(v)
  #       v = @regs.index(v)
  #       res += (0xFFF & v) << 5
  #     else
  #       res += 1 << 21
  #       v = v.to_i
  #       res += (0xFFFFF & v) << 5
  #     end
  #     res += (0b11111 & r2)
  #     res
  #   end

  def _getaddr(reg)
    if @regs.include?(reg)
      @regs.index(reg)
    elsif @labels.include?(reg)
      @labels[reg]
    else
      reg.to_i
    end
  end

  def _isvalue(reg)
    !@regs.include?(reg)
  end

  def op_binary(op, params)
    r1, v, r2 = params.include?(',') ? params.split(',') : params.split(' ')

    r2, v = v, r2 unless @regs.include?(v)

    if _isvalue(r2)
      op = @opcodes["#{op}i"] << 26
      r2 = _getaddr(r2) & 0x0000FFFF
    else
      op = @opcodes[op] << 26
      r2 = _getaddr(r2) << 11
    end

    r1 = _getaddr(r1) << 21
    v = _getaddr(v) << 16
    op | r1 | v | r2
  end

  def jmp(params)
    ra, rd = splitparams(params)
    rd, ra = ra, rd unless @regs.include?(rd)

    if _isvalue(rd)
      op = @opcodes['jmpi'] << 26
      rd = _getaddr(rd) & 0x000fffff
    else
      op = @opcodes['jmp'] << 26
      rd = _getaddr(rd) << 16
    end

    rd = _getaddr(rd) << 21

    op | rd | ra
    # res = @opcodes.index('jmp') << 26
    # label, r1 = r1, label unless @labels.include?(label)
    # r1 = _getaddr(r1)
    # label = _getaddr(label)
    # incl = @regs.include?(r1) ? 0 : 1
    # res += incl << 26
    # res += r1 << 5
    # res += label
    # res
  end

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

  def scall(param)
    op = @opcodes['scall'] << 26
    n = _getaddr(param) & 0x03ffffff
    op | n
  end

  def stop(_params)
    @opcodes['stop'] << 26
  end

  def splitparams(params)
    sep = params.include?(',') ? ',' : ' '
    params.split(sep)
  end

  def _isbinary(params)
    if params.nil? || params.empty?
      false
    else
      splitparams(params).length == 3
    end
  end

  def bin2hex(bin)
    # convert to hexadecimal
    res = bin.to_s(2).rjust(32, '0').scan(/.{4}/).map { |x| x.to_i(2).to_s(16) }.join
    # reverse bytes : 00 00 00 87 -> 87 00 00 00
    res.scan(/.{2}/).reverse.join
  end

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

  def _gencontent
    res = ''
    @assembled.each do |instruction|
      res += instruction
    end
    res
  end

  def printbinary
    puts @assembled
  end

  def exec(save = true)
    @labels = _readlabels
    @operations = _readops
    @assembled = _assemble
    res = _gencontent
    if save
      # check if output dir exists
      outdir = File.dirname(@output)
      Dir.mkdir(outdir) unless Dir.exist?(outdir)
      File.open(@output, 'w') do |f|
        # unpack the binary string into an array of 32-bit integers
        # and write it to the file
        f.write([res].pack('H*'))

      end
      puts "[Log/I]: Assembled file saved to #{@output}"
    else
      printbinary
    end
  end

end




a = Assembler.new('asm/fibo.asm', 'out/fibo.bin')
a.exec(true)
