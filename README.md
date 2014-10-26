## Elasticsearch の検索結果を無理やり csv に書きだすスクリプト

### これは何？

Elasticsearch に任意のクエリを投げて出力された結果を csv で出力します。

***

### 使い方

#### インデックスのドキュメント数とフィールドを確認する

チェックモードを使います。

~~~
./es-output2csv.rb -c
~~~

以下のように出力されます。

~~~
ドキュメント数:
"3"
ドキュメントフィールド一覧:
["field1", "field2", "field3"]
~~~

#### 検索結果を csv で出力します

幾つかのオプションを付けます。

| オプション | パラメータ例 | 用途 |
|:---|:---|:---|
| -f | field1,field2 | 出力するフィールド名を指定します |
| -s | field1 | 検索対象となるフィールド名を指定します |
| -q | Query | 検索文字を指定します |
| -r | 5000 | 検索結果の件数を指定します |

以下のように実行します。

~~~
./es-output2.csv.rb -f field1,field2 -s field1 -q Query -r 5000
~~~

また、デフォルトで CSV ファイルはカレントディレクトリの `test.csv` に出力されますが、ソースコード内の `config` メソッドのハッシュ定義を修正することで任意のファイルに出力することが可能です。

~~~
def config
  {
    :host => "127.0.0.1",
    :port => 9200,
    :date => 1,
    :index_prefix => "test_index",
    :type_prefix => "test",
    :csv_file => "test.csv"
  }
end
~~~

以下はハッシュキーと値の用途です。

| キー | 用途 |
|:---|:---|
| host | Elasticsearch のホストを指定します |
| port | Elasticsearch のポートを指定します |
| date | 今日から N 日前のインデックスの日付を指定します |
| index_prefix | index の prefix を指定します |
| type_prefix | index 内の type の prefix を指定します |
| csv_file | csv ファイルを指定します |

`logstash-YYYY.MM.DD` というインデックス名を想定した作りになっていますので、他のインデックス名を指定したい場合には `index_name` メソッドを適宜書き換えて下さい。

***

### 動作デモ

![](https://raw.githubusercontent.com/inokappa/es-output2csv/master/output.gif)
gif アニメーションでの動作デモです。止まっている場合にはリロードしてやって下さい。m(__)m

***

### FAQ

#### ネストされたドキュメントに対応しています？

 * しています

#### ネストされたドキュメントはどのように取り出しますか？

 * 上記のデモを御覧ください
 * 基本的には `hoge.huga.baz` ように指定することでドキュメントを取り出すことが出来ます

#### Elasticsearch のクエリ DSL

 * スクリプトで利用出来るクエリ DSL は `query string` のみです
 * クエリ文字に Lucene のクエリ文字が使えるかもしれません

#### エラー処理が無いんですけど...

 * すいません
 * ちゃんと作ります

***

### todo

 * エラー処理
 * Elasticsearch のホスト名、ポート名を引数で渡せるようにする
