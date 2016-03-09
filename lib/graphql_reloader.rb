require "digest/md5"

class GraphQLReloader
  delegate :changed?, to: :class
  delegate :checksum, to: :class

  def initialize(app)
    @app = app
  end

  def call(env)
    RelaySchema.dump_schema
    @app.call(env)
  end
end
