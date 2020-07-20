require "sinatra"
require "sinatra/reloader"
require 'pg'

# 【main】
project_dir = Dir.pwd
memo_files = {}

# トップ画面の表示：メモの一覧表示
def display_top(file_hash)
  @file_hash = file_hash
  erb :top
end

get '/top' do
  memos = {}
  # DBからデータを取得
  connection = PG::connect(:host => "localhost", :user => "sinatra", :password => "yuyuyuyu", :dbname => "sinatra")
  begin
    result = connection.exec("select * from memos")
    result.each do |value|
      memo_rows = value['contents'].split("\r")
      memos[value['id']] = memo_rows[0]
    end
  ensure
    connection.finish # コネクションを切断
  end
  # ファイルの読み込み　→　key:メモのID　value:メモタイトル
  @file_hash = memos
  erb :top
end

post '/new_memo' do
  # DBに保存
  sql = "INSERT INTO memos (contents) VALUES ('" + params[:text] + "')"
  connection = PG::connect(:host => "localhost", :user => "sinatra", :password => "yuyuyuyu", :dbname => "sinatra")
  begin
    result = connection.exec(sql)
  ensure
    connection.finish
  end
  redirect to ('/top')
end

get '/new_memo' do
  erb :new_memo
end

get '/show/:id' do
  sql = "select * from memos where id = '" + params[:id] + "'"
  # DBからデータを取得
  connection = PG::connect(:host => "localhost", :user => "sinatra", :password => "yuyuyuyu", :dbname => "sinatra")
  begin
    result = connection.exec(sql)
    @id = result[0]['id']
    @contents = result[0]['contents'].gsub("\n","<br>")
  ensure
    connection.finish # コネクションを切断
  end
  erb :show_memo
end

get '/memos/:id' do
  sql = "select * from memos where id = '" + params[:id] + "'"
  # DBからデータを取得
  connection = PG::connect(:host => "localhost", :user => "sinatra", :password => "yuyuyuyu", :dbname => "sinatra")
  begin
    result = connection.exec(sql)
    @id = result[0]['id']
    @contents = result[0]['contents']
  ensure
    connection.finish # コネクションを切断
  end
  erb :edit_memo
end

patch '/memos/:id' do
  sql = "UPDATE memos SET contents = '" + params[:text] + "' WHERE id = " + params[:id]
  # DBからデータを取得
  connection = PG::connect(:host => "localhost", :user => "sinatra", :password => "yuyuyuyu", :dbname => "sinatra")
  begin
    result = connection.exec(sql)
  ensure
    connection.finish # コネクションを切断
  end
  redirect to ('/top')
end

delete '/selected_memo/:id' do
  sql = "delete from memos where id = '" + params[:id] + "'"
  # DBからデータを取得
  connection = PG::connect(:host => "localhost", :user => "sinatra", :password => "yuyuyuyu", :dbname => "sinatra")
  begin
    result = connection.exec(sql)
  ensure
    connection.finish # コネクションを切断
  end
  redirect to ('/top')
end
