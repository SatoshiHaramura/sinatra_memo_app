# sinatra_memo_app

Sinatraを使ったメモアプリのリポジトリです。

# How to use

1. 右上の `Fork` ボタンを押してください。
2. `#{自分のアカウント名}/sinatra_memo_app` が作成されます。
3. 作業PCの任意の作業ディレクトリにて git clone してください。

```
$ git clone https://github.com/自分のアカウント名/sinatra_memo_app.git
```

4. PostgreSQLを起動させます。

```
# macOSにてHomebrewでPostgreSQLを管理している場合
$ brew services start postgresql
```

5. main.rbをrubyコマンドで実行し、メモアプリを起動させます。

```
$ bundle exec ruby main.rb
```

6. ブラウザからアクセスします。

```
http://localhost:4567
```
