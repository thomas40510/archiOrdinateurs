# class Assembler
# Opens an asm file and extracts the instructions to binary
# instantiate with Assembler.new('path_to_file', 'path_to_output_file')
#
class Assembler
  def initialize(file, output = 'out/output.bin')
    @ops = %w[stop ff add sub mul div and or xor shl shr slt sle seq load store jmp braz branz scall]
    @opcodes = {
      'add' => 0b00001,
      'sub' => 0b00010,
      'mul' => 0b00011,
      'div' => 0b00100,
      'and' => 0b00101,
      'or' => 0b00110,
      'xor' => 0b00111,
      'shl' => 0b01000,
      'shr' => 0b01001,
      'slt' => 0b01010,
      'sle' => 0b01011,
      'seq' => 0b01100,
      'load' => 0b01101,
      'store' => 0b01110,
      'jmp' => 0b01111,
      'braz' => 0b10000,
      'branz' => 0b10001,
      'scall' => 0b10010,
      'stop' => 0b00000
    }
    @regs = %w[zero r0 r1 r2 r3 r4 r5 r6 r7 r8 r9 r10 r11 r12 r13 r14 r15]
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
    if save
      File.open(@output, 'w') do |f|
        f.write(@assembled)
      end
    else
      printbinary
    end
  end

  def _readlabels
    labels = {}
    @content.each do |line|
      next unless line.include?(':')

      labels[line.split(':')[0]] = @content.index(line)
    end
    labels
  end

  def _readops
    ops = []
    @content.each do |line|
      next if line[0] == ';' || line.nil?

      line = line.split(': ')[1] if line.include?(':')
      next if line.nil?

      line = line.split(';')[0] if line.include?(';')
      @regexes.each do |op, regex|
        next unless line.match(regex)

        params = line.split(' ')[1]
        ops << [op.to_s, params.to_s]
      end
    end
    ops
  end

  def printops
    @operations = _readops
    @operations.each do |op|
      puts op
    end
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

  def op_ternary(op, params)
    r1, v, r2 = params.split(',')
    res = @opcodes[op] << 27
    res += @regs.index(r1) << 22
    res += if @regs.include?(v)
             0 << 21
           else
             1 << 21
           end
    res += (0xFFFFF & v.to_i) << 5 if @regs.include?(v)
    res += (0xFFFFF & v.to_i) << 5 unless @regs.include?(v)
    res += @regs.index(r2)

    res
  end

  def jmp(params)
    label, r1 = params.split(',')
    res = @opcodes['jmp'] << 27
    res += if @regs.include?(r1)
             0 << 26
           else
             1 << 26
           end
    res += @regs.index(r1) << 5
    res += @labels[label]
    res
  end

  def braz(params, op = 'braz')
    r, offset = params.split(',')
    res = @opcodes[op] << 27
    res += @regs.index(r) << 22
    res += @labels[offset].to_i
    res
  end

  def branz(params)
    braz(params, 'branz')
  end

  def scall(params)
    params = params.split(',')[0]
    res = @opcodes['scall'] << 27
    i = params.first.to_i
    res += (0b11111111111111111111 & i) << 5
    res
  end

  def stop(_params)
    0b00000
  end

  def _assemble
    # operations on 16 bits
    res = ''
    @operations.each do |op, params|
      calc = if params.split(',').length == 3
               op_ternary(op, params)
             else
               send(op, params)
             end
      calc = calc.to_s(16).rjust(8, '0')
      res += "#{calc}\n"
    end
    res
  end

  def printbinary
    puts @assembled
  end
end


a = Assembler.new('asm/matrix_3x3.asm', 'out/matrix.bin')
a.exec(false)
