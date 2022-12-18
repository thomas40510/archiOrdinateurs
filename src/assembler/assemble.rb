# class Assembler
# Opens an asm file and extracts the instructions to binary
# instantiate with Assembler.new('path_to_file', 'path_to_output_file')
#
class Assembler
  def initialize(file, output = 'out/output.bin')
    @opcodes = %w[stop add sub mul div and or xor shl shr slt sle seq load store jmp braz branz scall]
    @regs = %w[r0 r1 r2 r3 r4 r5 r6 r7 r8 r9 r10 r11 r12 r13 r14 r15]
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

  def exec(save = true)
    @labels = _readlabels
    @operations = _readops
    @assembled = _assemble
    res = _gencontent
    if save
      File.open(@output, 'w') do |f|
        f.write(res)
      end
      puts "[Log/I]: Assembled file saved to #{@output}"
    else
      printbinary
    end
  end

  def _readlabels
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
    ops = []
    @content.each do |line|
      next if line[0] == ';' || line.nil? || line.empty?

      line = line.split(';', 2)[0]
      next if line.nil? || line.empty?

      op, params = line.split(' ')
      if @opcodes.include?(op)
        ops << [op, params]
        puts "[Log/I]: Operation #{op} found with params #{params}"
      else
        puts "[Log/E]: Operation #{op} unknown at line #{line}"
      end
    end
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
    @regs.include?(reg) ? 0 : 1
  end

  def op_binary(op, params)
    r1, v, r2 = params.include?(',') ? params.split(',') : params.split(' ')

    res = @opcodes.index(op) << 27
    r1 = _getaddr(r1)
    v = _getaddr(v)
    r2 = _getaddr(r2)
    res += r1 << 22
    res += _isvalue(v) << 21
    res += if _isvalue(v) == 1
             v.to_i
           else
             _getaddr(v)
           end
    res += r2

    res.to_s(16)
  end

  def jmp(params)
    label, r1 = params.split(',')
    res = @opcodes.index('jmp') << 27
    label, r1 = r1, label unless @labels.include?(label)
    r1 = _getaddr(r1)
    label = _getaddr(label)
    incl = @regs.include?(r1) ? 0 : 1
    res += incl << 26
    res += r1 << 5
    res += label
    res.to_s(16)
  end

  def braz(params, op = 'braz')
    r, offset = params.split(',')
    offset, r = r, offset unless @regs.include?(r)
    res = @opcodes.index(op) << 27
    res += _getaddr(r) << 22
    res += _getaddr(offset)
    res.to_s(16)
  end

  def branz(params)
    braz(params, 'branz')
  end

  def scall(params)
    params.to_i.to_s(16)
  end

  def load(params)
    r1, r2, offset = params.split(',')
    res = @opcodes.index('load') << 27
    res += @regs.index(r1) << 22
    res += @regs.index(r2) << 5
    res += @labels[offset].to_i
    res.to_s(16)
  end

  def stop(_params)
    0b00000
  end

  def _isbinary(params)
    if params.nil? || params.empty?
      false
    else
      sep = params.include?(',') ? ',' : ' '
      params.split(sep).length == 3
    end
  end

  def _assemble
    # operations on 16 bits
    res = []

    @operations.each do |op, params|
      next unless @opcodes.include?(op)

      puts "[Log/I]: Assembling #{op} with #{params}"
      res << if _isbinary(params)
               op_binary(op, params)
             else
               send(op, params)
             end
    end
    res
  end

  def _gencontent
    res = ''
    @assembled.each do |instruction|
      res += "#{instruction}\n"
    end
    res
  end

  def printbinary
    puts @assembled
  end
end


a = Assembler.new('asm/12.asm', 'out/12.bin')
a.exec(true)
