class Song < ActiveRecord::Base
  include PgSearch
  pg_search_scope(
    :search_by_keywords,
    against: {name: 'A', lyrics: 'B', artist: 'B'},
    using: {:tsearch => {any_word: true, prefix: true}}
  )

  has_many :tags, through: :song_tags

  VALID_KEYS = Parser::MAJOR_KEYS
  VALID_TEMPOS = %w(Fast Medium Slow)
  MAX_LINE_LENGTH = 47

  before_validation :normalize

  validates :name, presence: true, uniqueness: { scope: :artist, message: "is taken by another song by this artist" }
  validates :key, presence: true
  validates_inclusion_of :key, in: VALID_KEYS, if: -> (song) { song.key.present? }
  validates :tempo, presence: true
  validates_inclusion_of :tempo, in: VALID_TEMPOS, if: -> (song) { song.tempo.present? }
  validates :chord_sheet, presence: true
  validate :line_length, if: -> (song) { song.chord_sheet.present? }

  before_save :extract_lyrics

  def to_s
    artist.blank? ? name : "#{name} by #{artist}"
  end

  private

  # Titlize fields and remove unnecessary spaces
  def normalize
    self.name = name.titleize.strip if name

    self.artist = artist.titleize.strip if artist

    if standard_scan
      self.standard_scan = standard_scan.upcase.split.each do |section_abbr|
        section_abbr.concat(".") if section_abbr[-1] != "."
      end.join(" ")
    end

    if chord_sheet
      normalized_lines = []
      chord_sheet.split("\n").each { |line| normalized_lines << line.rstrip }
      self.chord_sheet = normalized_lines.join("\n")
    end
  end

  def extract_lyrics
    lyrics = self.chord_sheet.split("\n").find_all { |line| Parser.lyrics?(line) }
    self.lyrics = lyrics.join("\n")
  end

  def line_length
    line_numbers = []
    self.chord_sheet.split("\n").each_with_index do |line, i|
      if(line.rstrip.length > MAX_LINE_LENGTH)
        line_numbers << (i + 1)
      end
    end
    if line_numbers.any?
      line_pluralized = 'line'.pluralize(line_numbers.length)
      line_numbers_string = line_numbers.join(',')
      errors.add(:chord_sheet, "#{line_pluralized}: #{line_numbers_string} cannot be longer than #{MAX_LINE_LENGTH} characters long")
    end
  end
end
