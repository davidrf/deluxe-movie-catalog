require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/flash'
require 'pg'

configure :development, :test do
  require 'pry'
end

Dir[File.join(File.dirname(__FILE__), 'lib', '**', '*.rb')].each do |file|
  require file
  also_reload file
end

def db_connection
  begin
    connection = PG.connect(dbname: "movies")
    yield(connection)
  ensure
    connection.close
  end
end

def next_page(page_param)
  if page_param && page_param.to_i >= 0
    page_param.to_i + 1
  else
    0
  end
end

def update_options(sort)
  options = {alph: "alph", year: "year", rating: "rating", app: "appearance"}
  sort ||= "alph"

  if sort == "alph"
    options[:alph] = "r_alph"
  elsif sort == "r_alph"
    options[:alph] = "alph"
  elsif sort == "year"
    options[:year] = "r_year"
  elsif sort == "r_year"
    options[:year] = "year"
  elsif sort == "rating"
    options[:rating] = "r_rating"
  elsif sort == "r_rating"
    options[:rating] = "rating"
  elsif sort == "appearance"
    options[:app] = "r_appearance"
  elsif sort == "r_appearance"
    options[:app] = "appearance"
  end

  options
end

def order_by_query_actors(sort)
  sort ||= "alph"

  if sort == "alph"
    query = " ORDER BY actors.name"
  elsif sort == "r_alph"
    query = " ORDER BY actors.name DESC"
  elsif sort == "appearance"
    query = " ORDER BY movie_count DESC"
  elsif sort == "r_appearance"
    query = " ORDER BY movie_count"
  end

  query
end

def order_by_query_movies(sort)
  sort ||= "alph"

  if sort == "alph"
    query = " ORDER BY movies.title"
  elsif sort == "r_alph"
    query = " ORDER BY movies.title DESC"
  elsif sort == "year"
    query = " ORDER BY movies.year DESC"
  elsif sort == "r_year"
    query = " ORDER BY movies.year"
  elsif sort == "rating"
    query = " ORDER BY movies.rating DESC NULLS LAST"
  elsif sort == "r_rating"
    query = " ORDER BY movies.rating NULLS FIRST"
  end

  query
end

def get_list_of(table, order, number)
  if table == "actors"
    query = "SELECT actors.id, actors.name, count(cast_members.actor_id) AS movie_count FROM actors
    JOIN cast_members ON actors.id = cast_members.actor_id
    GROUP BY actors.id"
    query += order_by_query_actors(order)
  elsif table == "movies"
    query = "SELECT movies.id, movies.title, movies.year, movies.rating,
    genres.name AS genre, studios.name AS studio FROM movies
    LEFT JOIN genres ON movies.genre_id = genres.id
    LEFT JOIN studios ON movies.studio_id = studios.id"
    query += order_by_query_movies(order)
  end

  query += " LIMIT 20 OFFSET #{number * 20}"

  list = []
  db_connection do |conn|
    list = conn.exec(query).to_a
  end
  list
end

def get_info_for(object, id)
  if object == "actor"
    query = "SELECT name FROM actors WHERE id = $1"
  elsif object == "movie"
    query = "SELECT movies.title, movies.year, movies.rating,
    genres.name AS genre, studios.name AS studio FROM movies
    LEFT JOIN genres ON movies.genre_id = genres.id
    LEFT JOIN studios ON movies.studio_id = studios.id
    WHERE movies.id = $1"
  end
  name = []
  db_connection do |conn|
    name = conn.exec_params(query, [id]).to_a[0]
  end
  name
end

def associated(objects, id)
  if objects == "movies"
    query = "SELECT movies.id, movies.title, cast_members.character FROM actors
    JOIN cast_members ON actors.id = cast_members.actor_id
    JOIN movies ON cast_members.movie_id = movies.id WHERE actors.id = $1"
  elsif objects == "characters"
    query = "SELECT cast_members.character AS name, actors.name AS actor,
    actors.id AS actor_id FROM actors
    JOIN cast_members ON actors.id = cast_members.actor_id
    JOIN movies ON cast_members.movie_id = movies.id WHERE movies.id = $1"
  end

  list = []
  db_connection do |conn|
    list = conn.exec(query, [id]).to_a
  end
  list
end

get '/' do
  redirect('/movies')
end

get '/movies' do
  @curr_order = params[:order] || "alph"
  @sort_options = update_options(params[:order])
  @page = next_page(params[:page])
  @movies = get_list_of("movies", params[:order], @page)
  erb :'movies/index'
end

get '/movies/:id' do |id|
  @movie = get_info_for("movie", id)
  @characters = associated("characters", id)
  erb :'movies/show'
end

get '/actors' do
  @curr_order = params[:order] || "alph"
  @sort_options = update_options(params[:order])
  @page = next_page(params[:page])
  @current_sort = params[:order]
  @actors = get_list_of("actors", params[:order], @page)
  erb :'actors/index'
end

get '/actors/:id' do |id|
  @actor = get_info_for("actor", id)
  @movies = associated("movies", id)
  erb :'actors/show'
end
