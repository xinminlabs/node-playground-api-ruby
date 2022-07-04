class App < Sinatra::Base
  register Sinatra::Cors

  set :allow_origin, '*'
  set :allow_headers, 'Accept,Authorization,Content-Type'
  set :allow_methods, 'GET,POST'

  set :public_folder, 'public'
  set :default_content_type, 'application/json'
  enable :logging

  get '/' do
    'Welcome to Node Playground!'
  end

  post '/generate-ast' do
    params = ActiveSupport::JSON.decode(request.body.read)
    node = generate_ast(params['code'])
    respond_ok(node: node)
  rescue StandardError => e
    respond_error(error: e.message)
  end

  post '/parse-nql' do
    params = ActiveSupport::JSON.decode(request.body.read)
    ranges = parse_nql(params['nql'], params['code'])
    respond_ok(ranges: ranges)
  rescue StandardError => e
    respond_error(error: e.message)
  end

  private

  def respond_error(body)
    halt 400, ActiveSupport::JSON.encode(body)
  end

  def respond_ok(body)
    ActiveSupport::JSON.encode(body)
  end

  def generate_ast(source)
    Parser::CurrentRuby.parse(source)
  end

  def parse_nql(nql, source)
    node = generate_ast(source)
    matching_nodes = NodeQuery.new(nql).parse(node)
    matching_nodes.map do |matching_node|
      start_loc = NodeMutation.adapter.get_start_loc(matching_node)
      end_loc = NodeMutation.adapter.get_end_loc(matching_node)
      {
        start: { line: start_loc.line, column: start_loc.column },
        end: { line: end_loc.line, column: end_loc.column }
      }
    end
  end
end