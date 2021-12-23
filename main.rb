#!/usr/bin/env ruby
# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'erb'
require 'pg'

class MemoManager
  DB_NAME = 'memodb'
  TABLE_NAME = 'memos'
  CONNECTION = PG.connect(dbname: DB_NAME)
  CONNECTION.prepare('all', "SELECT * FROM #{TABLE_NAME} ORDER BY id")
  CONNECTION.prepare('select', "SELECT * FROM #{TABLE_NAME} WHERE id = $1")
  CONNECTION.prepare('create', "INSERT INTO #{TABLE_NAME} (title, content) values ($1, $2)")
  CONNECTION.prepare('update', "UPDATE #{TABLE_NAME} SET title = $1, content = $2 WHERE id = $3")
  CONNECTION.prepare('delete', "DELETE FROM #{TABLE_NAME} WHERE id = $1")

  def self.connect
    MemoManager.new
  end

  def all
    CONNECTION.exec_prepared('all')
  end

  def find(id)
    CONNECTION.exec_prepared('select', [id]).first
  end

  def create(title, content)
    CONNECTION.exec_prepared('create', [title, content])
  end

  def update(id, title, content)
    CONNECTION.exec_prepared('update', [title, content, id])
  end

  def destroy(id)
    CONNECTION.exec_prepared('delete', [id])
  end
end

helpers do
  include ERB::Util

  def h(text)
    html_escape(text)
  end
end

not_found do
  erb :error_not_found
end

# GET / => トップページ
get '/' do
  memo_manager = MemoManager.connect
  @memos = memo_manager.all
  erb :index
end

# GET /memos/new => 新規作成ページ
get '/memos/new' do
  erb :new
end

# POST /memos => 新規作成する
post '/memos' do
  memo_manager = MemoManager.connect
  memo_manager.create(params[:title], params[:content])
  redirect to('/')
end

# GET /memos/1 => 詳細ページ
get '/memos/:id' do
  memo_manager = MemoManager.connect
  @memo = memo_manager.find(params[:id])
  erb :show
end

# GET /memos/1/edit => 編集ページ
get '/memos/:id/edit' do
  memo_manager = MemoManager.connect
  @memo = memo_manager.find(params[:id])
  erb :edit
end

# PATCH /memos/1 => 更新する
patch '/memos/:id' do
  memo_manager = MemoManager.connect
  memo_manager.update(params[:id], params[:title], params[:content])
  redirect to('/')
end

# DELETE /memos/1 => 削除する
delete '/memos/:id' do
  memo_manager = MemoManager.connect
  memo_manager.destroy(params[:id])
  redirect to('/')
end
