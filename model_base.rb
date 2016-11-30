class ModelBase

  def initialize
  end

  def self.find_by_id(id)
    table = QuestionsDB.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{self.tableize}
      WHERE
        id = ?
    SQL
    return nil if table.empty?
    self.class.new(table.first)
  end

  def self.tableize
    class_name = self.class.to_s
    words = class_name.scan(/[A-Z][a-z]+/).map(&:downcase)
    last_letter = words.last[-1]

    case last_letter
    when 'x', 's'
      words[-1] += 'es'
    when 'y'
      words[-1] = words.last[0..-2] + 'ies'
    else
      words[-1] += 's'
    end

    words.join('_')
  end

  def self.all
    data = QuestionsDB.instance.execute("SELECT * FROM #{self.tableize}")
    data.map { |datum| self.class.new(datum) }
  end
end
