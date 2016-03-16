require "digest/md5"

class GraphQLReloader < Struct.new :app
  delegate :changed?, to: :class
  delegate :checksum, to: :class

  def call(env)
    # GraphQL::Introspection::INTROSPECTION_QUERY
    RelaySchema.dump_schema
    app.call(env)
  end
end
