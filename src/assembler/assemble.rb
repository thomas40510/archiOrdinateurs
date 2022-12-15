# class Assembler
# Opens an asm file and extracts the instructions to binary
# instantiate with Assembler.new('path_to_file', 'path_to_output_file')
#
class Assembler
  def initialize(file, output = 'out/output.bin')
    @opcodes = %w[stop add sub mul div and or xor shl shr slt sle seq load store jmp braz branz scall]
    @regs = %w[zero r0 r1 r2 r3 r4 r5 r6 r7 r8 r9 r10 r11 r12 r13 r14 r15]
    @regexes = {
      'stop' => /stop/,
      'add' => /add\s(r[0-9]|zero),((r|)[0-9]|zero),(r[0-9]|zero)/,
      'sub' => /sub\s(r[0-9]|zero),((r|)[0-9]|zero),(r[0-9]|zero)/,
      'mul' => /mul\s(r[0-9]|zero),((r|)[0-9]|zero),(r[0-9]|zero)/,
      'div' => /div\s(r[0-9]|zero),((r|)[0-9]|zero),(r[0-9]|zero)/,
      'and' => /and\s(r[0-9]|zero),(r[0-9]|zero),(r[0-9]|zero)/,
      'or' => /or\s(r[0-9]|zero),(r[0-9]|zero),(r[0-9]|zero)/,
      'xor' => /xor\s(r[0-9]|zero),(r[0-9]|zero),(r[0-9]|zero)/,
      'shl' => /shl\s(r[0-9]|zero),(r[0-9]|zero),(r[0-9]|zero)/,
      'shr' => /shr\s(r[0-9]|zero),(r[0-9]|zero),(r[0-9]|zero)/,
      'slt' => /slt\s(r[0-9]|zero),(r[0-9]|zero),(r[0-9]|zero)/,
      'sle' => /sle\s(r[0-9]|zero),(r[0-9]|zero),(r[0-9]|zero)/,
      'seq' => /seq\s(r[0-9]|zero),(r[0-9]|zero),(r[0-9]|zero)/,
      'load' => /load\s(r[0-9]|zero),(r[0-9]|zero),([0-9]|zero)/,
      'store' => /store\s(r[0-9]|zero),(r[0-9]|zero),([0-9]|zero)/,
      'jmp' => /jmp\s(\w*),(r[0-9]|zero)/,
      'braz' => /braz\s(r[0-9]|zero),([0-9]|zero)/,
      'branz' => /branz\s(r[0-9]|zero),([0-9]|zero)/,
      'scall' => /scall\s([0-9]|zero)/,
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

  def exec
    @labels = _readlabels
    @operations = _readops
    @assembled = _assemble
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
      next if line[0] == ';'

      line = line.split(': ')[1] if line.include?(':')
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

  def op_ternary(op, params)
    r1, v, r2 = params.split(',')
    raise "Error in #{op} #{params}" unless @regs.include?(r1) && @regs.include?(r2)

    res = @opcodes.index(op) << 27
    r1 = @regs.index(r1)
    r2 = @regs.index(r2)
    res += r1 << 22
    if @regs.include?(v)
      v = @regs.index(v)
      res += (0xFFF & v) << 5
    else
      res += 1 << 21
      v = v.to_i
      res += (0xFFFFF & v) << 5
    end
    res += (0b11111 & r2)

    res
  end

  def jump(params)
    # handle jump to label
    res = @opcodes.index('jmp') << 27
    res.to_s
  end

  def _assemble
    # operations on 16 bits
    res = ''
    @operations.each do |op, params|
      case op
      when 'stop'
        puts 'stop'
      when 'jmp'
        res += jump(params)
      when 'braz', 'branz'
        puts 'braz'
      when 'scall'
        puts 'scall'
      else
        res += op_ternary(op, params).to_s
      end
    end
    res
  end
  
  def printbinary
    puts @assembled
  end
end


a = Assembler.new('asm/chenillard.asm', '../../bin/chenillard.bin')
a.exec
a.printbinary
