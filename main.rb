#!/usr/bin/env ruby
# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/json'
require 'erb'

class Memo
  DATA_FILE_PATH = './db/memo_data.json'

  attr_reader :memos

  def initialize(memos)
    @memos = memos
  end

  def self.read
    memos = File.open(DATA_FILE_PATH) { |f| JSON.parse(f.read) }
    Memo.new(memos['memos'])
  end

  def write
    memos = { "memos": @memos }
    File.open(DATA_FILE_PATH, 'w') { |f| JSON.dump(memos, f) }
  end

  def find(id)
    @memos.find { |memo| memo['id'] == id }
  end

  def create(title, content)
    id = if @memos != []
           @memos.last['id'].to_i + 1
         else
           1
         end
    add_data = { 'id': id.to_s, 'title': title, 'content': content }
    @memos << add_data
  end

  def update(id, title, content)
    @memos.each_with_index do |memo, i|
      if memo['id'] == id
        @memos[i]['title'] = title
        @memos[i]['content'] = content
      end
    end
  end

  def destroy(id)
    @memos.each_with_index do |memo, i|
      @memos.delete_at i if memo['id'] == id
    end
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
  @memo_list = Memo.read
  erb :index
end

# GET /memos/new => 新規作成ページ
get '/memos/new' do
  erb :new
end

# POST /memos => 新規作成する
post '/memos' do
  memo = Memo.read
  memo.create(h(params[:title]), h(params[:content]))
  memo.write
  redirect to('/')
end

# GET /memos/1 => 詳細ページ
get '/memos/:id' do
  memo = Memo.read
  @memo = memo.find(params[:id])
  erb :show
end

# GET /memos => 編集ページ
get '/memos/:id/edit' do
  memo = Memo.read
  @memo = memo.find(params[:id])
  erb :edit
end

# PATCH /memos => 更新する
patch '/memos/:id' do
  memo = Memo.read
  memo.update(params[:id], h(params[:title]), h(params[:content]))
  memo.write
  redirect to('/')
end

# DELTE /memos/:id => 削除する
delete '/memos/:id' do
  memo = Memo.read
  memo.destroy(params[:id])
  memo.write
  redirect to('/')
end
