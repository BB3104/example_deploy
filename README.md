# README

## rails + capistrano + wercker + AWS EC2 の自動デプロイ構築メモ

## 開発環境
- MAC OS
- 前提 rbenvでrubyが管理できている状態
- railsのプロジェクト作成済み

## デプロイ先環境
- Amazon Linux


## デプロイ先サーバーの構築手順
#### git インストール

```
sudo yum -y install git
```
#### rbenv インストール
rubyのバージョン管理が可能なツールです
```
$ git clone git://github.com/sstephenson/rbenv.git ~/.rbenv
$ echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
$ echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
$ source ~/.bash_profile
$ rbenv -v
```

#### ruby-build インストール
ruby をインストールするために必要
```
$ git clone git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
```
ruby インストールに必要なので先にインストールする
```
$ sudo yum install -y gcc make openssl-devel readline-devel
```
ruby インストール
```
$ rbenv install 2.3.0
$ rbenv global 2.3.0
$ rbenv rehash
$ rbenv versions
$ ruby -v
```

## 開発環境での準備
### capistranoの設定

railsプロジェクトのGemfileに追記
```
gem 'therubyracer', platforms: :ruby # コメント外す
...

gem 'capistrano', '~> 3.4.0'
gem 'capistrano-rails', '~> 1.1.3' #バージョン指定しないとエラーでた
gem 'capistrano-bundler', '~> 1.1.2'
gem 'capistrano-rbenv'
```
これで解決した記事
http://qiita.com/pugiemonn/items/11a2bc8403e5947a8f13
http://qiita.com/ikm/items/5d434e6e6077cac16c6d

プロジェクトディレクトリ上で
bundle インストール
```
bundle exec install --path vendor/bundle
```

```
bundle exec cap install
```

```
$ tree
├── Capfile
├── Gemfile
├── Gemfile.lock
├── config
│   ├── deploy
│   │   ├── production.rb
│   │   └── staging.rb
│   └── deploy.rb
└── lib
    └── capistrano
            └── tasks
```

あとは参考URLみながらなんとか動くようになった
参考URL
http://qiita.com/naoki_mochizuki/items/657aca7531b8948d267b

capistranoからsshするユーザーにできるようにする<br>
デプロイ先のプロジェクトの権限をデプロイユーザーにしておく<br>
```
sudo chown -R deploy /var/www/プロジェクト
```


### Werckerの設定
werckerとgithubを連携させる<br>
http://www.wercker.com/ から対象のリポジトリを登録する<br>

作成場所はプロジェクトディレクトリの直下<br>
```
.
├── Capfile
├── Gemfile
├── Gemfile.lock
├── README.md
├── Rakefile
├── app
├── bin
├── config
├── config.ru
├── db
├── lib
├── log
├── public
├── test
├── tmp
├── vendor
└── wercker.yml
```

githubのリモートにpushすると、werckerがそれを検知してbuildが実行される。<br>
その際にwercker.ymlで設定したbuildというタスクが実行される。<br>

wercker.ymlで実行させたい処理を追記する。<br>
今回だとdeploy、deploy-rollbackを追加して、これをwerckerサイトでWorkflowsに登録して実行させるとデプロイ先サーバーにデプロイが実行される




