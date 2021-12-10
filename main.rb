#!/usr/bin/env ruby
# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/json'
require 'erb'

class MemoManager
  DATA_FILE_PATH = './db/memo_data.json'

  attr_reader :memos

  def initialize(memos)
    @memos = memos
  end

  def self.read
    memos = File.open(DATA_FILE_PATH) { |f| JSON.parse(f.read) }
    MemoManager.new(memos['memos'])
  end

  def find(id)
    @memos.find { |memo| memo['id'] == id }
  end

  def create(title, content)
    id = @memos.empty? ? 1 : @memos.last['id'].to_i + 1
    add_data = { 'id': id.to_s, 'title': title, 'content': content }
    @memos << add_data
    write
  end

  def update(id, title, content)
    @memos.each do |memo|
      if memo['id'] == id
        memo['title'] = title
        memo['content'] = content
      end
    end
    write
  end

  def destroy(id)
    @memos.delete_if { |memo| memo['id'] == id }
    write
  end

  private

  def write
    memos = { "memos": @memos }
    File.open(DATA_FILE_PATH, 'w') { |f| JSON.dump(memos, f) }
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
  memo_manager = MemoManager.read
  @memos = memo_manager.memos
  erb :index
end

# GET /memos/new => 新規作成ページ
get '/memos/new' do
  erb :new
end

# POST /memos => 新規作成する
post '/memos' do
  memo_manager = MemoManager.read
  memo_manager.create(params[:title], params[:content])
  redirect to('/')
end

# GET /memos/1 => 詳細ページ
get '/memos/:id' do
  memo_manager = MemoManager.read
  @memo = memo_manager.find(params[:id])
  erb :show
end

# GET /memos/1/edit => 編集ページ
get '/memos/:id/edit' do
  memo_manager = MemoManager.read
  @memo = memo_manager.find(params[:id])
  erb :edit
end

# PATCH /memos/1 => 更新する
patch '/memos/:id' do
  memo_manager = MemoManager.read
  memo_manager.update(params[:id], params[:title], params[:content])
  redirect to('/')
end

# DELETE /memos/1 => 削除する
delete '/memos/:id' do
  memo_manager = MemoManager.read
  memo_manager.destroy(params[:id])
  redirect to('/')
end
