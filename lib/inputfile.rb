class InputFile
  def initialize(pathname)
    @pathname = pathname
  end

  REMAP = {
    'item' => 'id',

    'party' => 'P4100',
    'group' => 'P4100',

    'area' => 'P768',
    'constituency' => 'P768',

    'start' => 'P580',
    'starttime' => 'P580',
    'startdate' => 'P580',
    'start_time' => 'P580',
    'start_date' => 'P580',

    'end' => 'P582',
    'endtime' => 'P582',
    'enddate' => 'P582',
    'end_time' => 'P582',
    'end_date' => 'P582',

    'replaces' => 'P1365',

    'replaced_by' => 'P1366',
    'replacedby' => 'P1366',
    'replacedBy' => 'P1366',

    'cause' => 'P1534',
    'end_cause' => 'P1534',
    'endcause' => 'P1534',
  }

  def data
    # TODO: warn about unexpected keys in either file
    @data ||= raw.map do |row|
      row.transform_keys { |k| REMAP.fetch(k.to_s, k).to_sym }
        .transform_values do |v|
          v = v[:value] if v.class == Hash
          v.to_s.sub('T00:00:00Z','')
        end
    end
  end

  def find(id)
    data.select { |row| row[:id] == id }
  end

  attr_reader :pathname

  class CSV < InputFile
    require 'csv'

    def raw
      @data ||= ::CSV.table(pathname).map(&:to_h)
    end
  end

  class JSON < InputFile
    require 'json'

    def raw
      @data ||= ::JSON.parse(pathname.read, symbolize_names: true)
    end
  end
end
