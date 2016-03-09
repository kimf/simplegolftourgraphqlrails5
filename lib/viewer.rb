class Viewer
  def initialize(id)
    @id = id
  end
  # HACK: For relay root queries
  # INFO: https://github.com/facebook/relay/issues/112
  STATIC = new(id: "root").freeze

  def self.find(_)
    STATIC
  end
end
