require 'mysql'
require 'open-uri'
require 'houston'
require 'json'
require './PBDBConnector.rb'

string = ""

conn = PBDBConn.new
apn = Houston::Client.production
certs = JSON.parse(File.read("./certs.json"))
apn.certificate = File.read(certs["pro_cert"])

users = conn.getUsersList
users.each_hash do |h|
  uuid = h["UUID"]
  notification = Houston::Notification.new(device: uuid)
  notification.alert = string
  apn.push(notification)
end

conn.close