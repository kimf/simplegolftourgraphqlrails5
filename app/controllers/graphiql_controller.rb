class GraphiqlController < ApplicationController
  def index
    render file: "public/graphiql.html"
  end
end
