# class Assembler
# Opens an asm file and extracts the instructions to binary
# instantiate with Assembler.new('path_to_file', 'path_to_output_file')
#
class Assembler
  def initialize(file, output = 'out/output.bin')
    @opcodes = %w[stop add sub mul div and or xor shl shr slt sle seq load store jmp braz branz scall]
    @regs = %w[zero r0 r1 r2 r3 r4 r5 r6 r7 r8 r9 r10 r11 r12 r13 r14 r15]
    @regexes = {
      "stop": 'lll',
    }

    @source = file
    @content = []
    @operations = []
    @output = output
    @assembled = ''
  end

  # displays the operations and their parameters

  def exec
    @content = _readfile
    @labels = _readlabels
    @operations = _readops
    @assembled = _assemble
    _writeoutput
  end

  def _readfile
    res = []
    f = File.open(@source, 'r').readlines
    f.each do |line|
      line = line.split(';')[0]
      next if ["\n", ''].include?(line)

      res << line
      # res << line.split(';')[0] if (line[0] != ';') && (line != '') && (line[0] != '#') && (line[0] != "\n")
    end
    res
  end

  def _readlabels
    labels = {}
    @content.each do |line|
      if line.include?(':')
        label = line.split(': ')[0]
        labels[label] = @content.index(line)
        puts labels
      end
    end
    labels
  end

  # @return list of found operations and their parameters
  def _readops
    ops = []
    @content.each do |line|
      line = line.split(';')[0] if line.include?(';')
      line = line.split(': ')[1] if line.include?(':')

      begin
        op, params = line.split(' ')
        params = params.split(',')
        ops << [op, params] if @opcodes.include?(op)
      end
    end
    ops
  end

  def _assemble
    # write on 16 bits
    res = ''
    @operations.each do |op, params|
      case op
      when 'jmp'
        res << @opcodes.index(op).to_s(2).rjust(4, '0')
        res << @regs.index(params[0]).to_i.to_s(2).rjust(4, '0')
        res << @labels[params[1]].to_i.to_s(2).rjust(8, '0')
      when 'braz', 'branz'
        res << @opcodes.index(op).to_s(2).rjust(4, '0')
        res << @regs.index(params[0]).to_i.to_s(2).rjust(4, '0')
        res << @labels[params[1]].to_s(2).rjust(8, '0')
      when 'load', 'store'
        res << @opcodes.index(op).to_s(2).rjust(4, '0')
        res << @regs.index(params[0]).to_i.to_s(2).rjust(4, '0')
        res << params[1].to_s(2).rjust(4, '0')
        res << params[2].to_s(2).rjust(4, '0')
      when 'scall'
        res << @opcodes.index(op).to_s(2).rjust(4, '0')
        res << @regs.index(params[0]).to_s(2).rjust(4, '0')
        res << @regs.index(params[1]).to_s(2).rjust(4, '0')
        res << params[2].to_s(2).rjust(4, '0')
      else
        res << ternary(op, params)
      end
    end
    res
  end

  def ternary(op, params)
    res = ''
    res << @opcodes.index(op).to_s(2).rjust(4, '0')
    res << @regs.index(params[0]).to_s(2).rjust(4, '0')
    res << params[1].to_i.to_s(2).rjust(4, '0')
    res << @regs.index(params[2]).to_s(2).rjust(4, '0')
    puts res
    res
  end

  def _writeoutput
    f = File.open(@output, 'w')
    f.write(@assembled)
    f.close
    puts "Wrote text to #{@output}"
  end
end


a = Assembler.new('asm/chenillard.asm', '../../bin/chenillard.bin')
a.exec
