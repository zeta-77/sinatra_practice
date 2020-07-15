require "sinatra"
require "sinatra/reloader"

# ファイルハッシュの生成 → key:ファイル名　value:１行目（タイトル）
def make_file_hash(project_dir)
  memo_files = {}
  Dir.chdir(project_dir + '/memo')
  Dir.glob('*').sort.each do |file_name|
    file = File.open(file_name, 'r')
    temp = file.gets
    first_line = temp.gsub("\n", '')
    memo_files[file_name] = first_line 
  end
  Dir.chdir(project_dir)
  memo_files
end

# 【main】
project_dir = Dir.pwd
memo_files = {} 

# トップ画面の表示：メモの一覧表示
def display_top(file_hash)
  @file_hash = file_hash
  erb :top
end

get '/top' do
  # ファイルの読み込み　→　key:タイトル　value:ファイル名
  memo_files = make_file_hash(project_dir) # key:１行目　value:ファイル名
  @file_hash = memo_files
  erb :top
end

post '/save_new_memo' do
  # ファイル名の生成
  Dir.chdir('./memo')
  files = []
  Dir.glob('*').each do |file|
    files.push(file.gsub('memo','').to_i)
  end
  # ファイルの保存　→　ファイル名 = memo+連番
  file_name = 'memo' + (files.max + 1).to_s.rjust(5, '0')
  File.open(file_name, 'w'){|f|
    f.write(params[:text])
  }
  redirect to ('/top')
end

get '/new_memo' do
  erb :new_memo
end

get '/show/:file_name' do
  file = File.open('memo/' + params[:file_name], 'r')
  @content = file.read.gsub("\n","<br>")
  @file_name = params[:file_name]
  erb :show_memo
end

get '/memos/:file_name' do
  file = File.open('memo/' + params[:file_name], 'r')
  @file_name = params[:file_name]
  @content = file.read  
  erb :edit_memo
end

patch '/memos/:file_name' do
  # 対象ファイル削除
  File.delete('./memo/' + params[:file_name])
  # ファイルの保存　→　ファイル名 = memo+連番
  File.open('memo/' + params[:file_name], 'w'){|f|
    f.write(params[:text])
  }
  redirect to ('/top')
end

delete '/selected_memo/:file_name' do
  File.delete('./memo/' + params[:file_name])
  @file_hash = make_file_hash(project_dir)
  redirect to ('/top')
end
