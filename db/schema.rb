# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20131118065727) do

  create_table "changehistory", force: true do |t|
    t.string "host"
    t.string "hoshhash", limit: 32
    t.string "type",     limit: 20
    t.string "before"
    t.string "now"
    t.string "memo"
  end

  create_table "ipaddr", force: true do |t|
    t.string "ip",       limit: 16
    t.string "iphash",   limit: 32
    t.string "country",  limit: 100
    t.string "province"
    t.string "city"
  end

  add_index "ipaddr", ["iphash"], name: "iphash", unique: true, using: :btree

  create_table "rootdomain", force: true do |t|
    t.string    "domain",                    null: false
    t.string    "domainhash",     limit: 32
    t.integer   "alexa"
    t.timestamp "lastupdatetime"
    t.timestamp "lastchecktime"
  end

  add_index "rootdomain", ["domain"], name: "domain", unique: true, using: :btree
  add_index "rootdomain", ["domainhash"], name: "hash", unique: true, using: :btree

  create_table "subdomain", force: true do |t|
    t.string    "host",                      null: false
    t.string    "hosthash",       limit: 32
    t.string    "subdomain"
    t.string    "domain"
    t.string    "ip"
    t.text      "header"
    t.string    "title"
    t.string    "pr"
    t.timestamp "lastupdatetime"
    t.timestamp "lastchecktime"
    t.string    "memo"
    t.text      "body"
    t.string    "app"
  end

  add_index "subdomain", ["host"], name: "host", unique: true, using: :btree
  add_index "subdomain", ["hosthash"], name: "hash", unique: true, using: :btree

  create_table "subdomains", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tag", force: true do |t|
    t.string   "hosthash"
    t.text     "tag"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tags", force: true do |t|
    t.string    "hosthash",   limit: 32, null: false
    t.string    "tag",        limit: 32, null: false
    t.timestamp "updatetime"
  end

  add_index "tags", ["hosthash", "tag"], name: "hosthash_tag", unique: true, using: :btree

end
