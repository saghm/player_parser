module PlayerParser
  class Season
    def initialize(data, row)
      cells = row.css('td')

      data.each { |d, i| instance_variable_set(:"@_#{d}", cells[i].text) }
    end

    def to_hash
      instance_variables.reduce({}) do |hash, var|
        value = self.instance_variable_get(var).to_f
        value = value.to_i if value % 1 == 0
        hash[var[1..-1].intern] = value
        hash
      end
    end
  end
end
