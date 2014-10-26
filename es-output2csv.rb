#!/usr/bin/env ruby
# encoding: utf-8

require 'csv'
require 'json'
require 'net/http'
require 'optparse'

def config
  {
    :host => "your_elasticsearch_host",
    :port => 9200,
    :date => 0,
    :index_prefix => "your_index_name",
    :type_prefix => "your_type_name",
    :csv_file => "test.csv"
  }
end

# Index の日付を確認
def index_date
  d = Date.today
  d = d - config[:date]
  d.strftime("%Y.%m.%d")
end

# Index の名前を生成
def index_name
  "#{config[:index_prefix]}-#{index_date}"
end

# Elasticsearch のホストを定義
def request_uri
  URI.parse("http://#{config[:host]}:#{config[:port]}/")
end

# Elasticsearch へのリクエスト
def get_respons(request)
  begin
    Net::HTTP.start(request_uri.host, request_uri.port, :open_timeout => 10) do |http|
      http.request(request)
    end
  rescue => ex
    puts ex.message
  end
end

# ドキュメント数を取得する
def check_max_document_count
  req = request_uri.path + "_cat/count/" + "#{index_name}"
  request = Net::HTTP::Get.new(req)
  begin
    res = get_respons request
    count = res.body.split(nil)
    count[2]
  rescue => ex
    puts ex.message
  end
end

# ドキュメントのフィールド名を取得する
def check_document_field_name
  req = request_uri.path + "#{index_name}" + "/_mapping"
  request = Net::HTTP::Get.new(req)
  begin
    res = get_respons request
    json = JSON.parse(res.body)
    fields = json.values[0]["mappings"][config[:type_prefix]]["properties"].keys
  rescue => ex
    puts ex.message
  end
end

# ドキュメントを検索して結果を返す
def search_document(*params)
  req = request_uri.path + "#{index_name}" + "/_search"
  request = Net::HTTP::Post.new(req, initheader = {'Content-Type' =>'application/json'})
  begin
    request.body = { from: 0, size: params[3], fields: params[0].split(","), query:{ simple_query_string: { fields: params[1].split(","), query: params[2] }}}.to_json
    res = get_respons request
    JSON.parse(res.body)
  rescue => ex
    puts ex.message
  end
end

# 検索結果を利用して csv で出力する
def convert_to_csv(res)
  CSV.open("#{config[:csv_file]}", "w") do |csv| 
    csv << res["hits"]["hits"][0]["fields"].keys
    res["hits"]["hits"].each do |v|
      record = []
      v["fields"].values.flatten.each do |r|
        record << r.strip.split(",")
      end
      csv << record.flatten
    end
  end  
end

# main
params = ARGV.getopts('f:s:q:r:c')
if params["c"]
  puts "ドキュメント数:" 
  p check_max_document_count
  puts "\n"
  puts "ドキュメントフィールド一覧:"
  p check_document_field_name
  puts "\n"
else
  res = search_document(params["f"],params["s"],params["q"],params["r"])
  convert_to_csv(res)
end
