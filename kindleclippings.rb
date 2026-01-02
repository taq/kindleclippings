# typed: false
# frozen_string_literal: true

class Book
  attr_accessor :title, :author, :notes

  def initialize(title, author)
    @title  = title
    @author = author
    @notes  = {}
  end

  def print
    puts "#{@title} - #{@author}"
    puts '-' * 80
    puts "\n"

    for pos, note in @notes
      sep = "-" * pos.size
      puts "#{pos}\n#{sep}\n#{note.text.join("\n")}\n\n"
    end
  end
end

class Note
  attr_accessor :position, :text

  def initialize(position, text)
    @position = position
    @text     = text
  end
end

file   = ARGV[0].to_s
filter = ARGV[1].to_s

if file.size < 1
  STDERR.puts "Error: need a file name"
  return
end

unless File.exist?(file)
  STDERR.puts "Error: file #{file} does not exist"
  return
end

title = true
date  = false
books = {}
bref  = nil
pref  = nil

title_exp = /^(?<title>.*) \((?<author>.*)\)/
pos_exp   = /(?<pos>\d+(-\d+)?)/

File.open(file).each do |line|
  line = line.chomp

  if title
    matches = line.match(title_exp)

    if matches
      title   = false
      date    = true
      bref    = line
      books[bref] ||= Book.new(matches[:title], matches[:author])
      next
    end
  end

  if date
    matches = line.match(pos_exp)

    if matches
      pref    = matches[:pos]
      date    = false
      books[bref].notes[pref] ||= Note.new(pref, [])
      next
    end
  end

  if line == '=========='
    bref  = nil
    pref  = nil
    title = true
    date  = false
    next
  end

  next if line.size < 1

  next unless books[bref] && books[bref].notes[pref]

  books[bref].notes[pref].text << line
end

if filter.size > 0
  filter_exp = Regexp.new(filter, true)
  books = books.select { |key, book| book.title.match?(filter_exp) }
end

for key, book in books
  book.print
end
