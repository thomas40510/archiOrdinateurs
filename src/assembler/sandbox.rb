# frozen_string_literal: true

# @!attribute [r] sandbox
# @return [String] The path to the sandbox directory.
class AssemblerOld
  def initialize(file)
    @source = file
    @instructions = instructions_from_source
  end

  def open_source
    File.open(@source, 'r')
  end

  def instructions_from_source
    open_source.readlines
  end

  @corresponding_opcodes = {
    'stop' => 0,
    'add' => 1,
    'sub' => 2,
    'mul' => 3,
    'div' => 4,
    'and' => 5,
    'or' => 6,
    'xor' => 7,
    'shl' => 8,
    'shr' => 9,
    'slt' => 10,
    'sle' => 11,
    'seq' => 12,
    'load' => 13,
    'store' => 14,
    'jmp' => 15,
    'braz' => 16,
    'branz' => 17,
    'scall' => 18,
  }

  def extract_instructions
    @instructions.each do |line|
      case line
      when /add/
        add line.split(' ')[1]
      when /sub/
        sub line.split(' ')[1]
      when /jmp/
        jump line.split(' ')[1]
      when /seq/
        seq line.split(' ')[1]
      when /shl/
        shl line.split(' ')[1]
      when /braz/
        braz line.split(' ')[1]
      when /store/
        store line.split(' ')[1]
      else
        if line =~ /;/
          puts "===CommentLine #{line}"
        else
          puts "//other: #{line}"
        end
      end
    end
  end

  def add(params)
    puts "add #{params}"
  end

  def sub(params)
    puts "sub #{params}"
  end

  def jump(params)
    puts "jmp #{params}"
  end

  def seq(params)
    puts "seq #{params}"
  end

  def shl(params)
    puts "shl #{params}"
  end

  def braz(params)
    puts "braz #{params}"
  end

  def store(params)
    puts "store #{params}"
  end
end

def complement(value, size = 16)
  if value >= 0
    value
  else
    (1 << (size - 1)) - value
  end
end


# Assembler.new('asm/matrix_3x3.asm').extract_instructions
