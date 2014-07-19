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

ActiveRecord::Schema.define(version: 20140719033820) do

  create_table "active_admin_comments", force: true do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "analysis_info", force: true do |t|
    t.text "server_info"
    t.text "cms_info"
    t.text "cloudsec_info"
    t.date "writedate"
  end

  add_index "analysis_info", ["writedate"], name: "writedate", unique: true, using: :btree

  create_table "changehistory", force: true do |t|
    t.string "host"
    t.string "hoshhash", limit: 32
    t.string "type",     limit: 20
    t.string "before"
    t.string "now"
    t.string "memo"
  end

  create_table "error_host", force: true do |t|
    t.string    "host"
    t.string    "hosthash",       limit: 32
    t.timestamp "lastupdatetime"
    t.text      "reason"
  end

  add_index "error_host", ["hosthash"], name: "hosthash", unique: true, using: :btree

  create_table "gov_site", force: true do |t|
    t.string  "host"
    t.integer "subdomain_id"
    t.string  "ip",                  limit: 20
    t.string  "ip_province",         limit: 20
    t.string  "ip_city",             limit: 30
    t.string  "ip_province_chinese", limit: 20
    t.string  "ip_city_chinese",     limit: 30
    t.string  "sure_province",       limit: 20
    t.string  "sure_city",           limit: 30
  end

  add_index "gov_site", ["host"], name: "host", unique: true, using: :btree
  add_index "gov_site", ["subdomain_id"], name: "subdomain_id", unique: true, using: :btree

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

  create_table "rule", force: true do |t|
    t.string   "product"
    t.string   "producturl"
    t.string   "rule"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.boolean  "published"
  end

  create_table "sph_counter", primary_key: "counter_id", force: true do |t|
    t.integer   "max_id",       limit: 8,               null: false
    t.integer   "min_id",                  default: 1,  null: false
    t.string    "index_name",   limit: 32, default: "", null: false
    t.timestamp "last_updated",                         null: false
  end

  add_index "sph_counter", ["index_name"], name: "index_name", using: :btree

  create_table "subdomain", force: true do |t|
    t.string    "host",                      null: false
    t.string    "hosthash",       limit: 32
    t.string    "subdomain"
    t.string    "domain"
    t.string    "reverse_domain"
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
  add_index "subdomain", ["lastupdatetime"], name: "updatetime", using: :btree
  add_index "subdomain", ["reverse_domain"], name: "reverse_domain", using: :btree

  create_table "tags", force: true do |t|
    t.string    "hosthash",   limit: 32,             null: false
    t.string    "tag",        limit: 32,             null: false
    t.integer   "tag_type",              default: 0, null: false
    t.timestamp "updatetime"
  end

  add_index "tags", ["hosthash", "tag"], name: "hosthash_tag", unique: true, using: :btree
  add_index "tags", ["hosthash"], name: "hosthash", using: :btree

  create_table "user", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.boolean  "isadmin"
  end

  add_index "user", ["email"], name: "index_user_on_email", unique: true, using: :btree
  add_index "user", ["reset_password_token"], name: "index_user_on_reset_password_token", unique: true, using: :btree
  add_index "user", ["username"], name: "index_user_on_username", unique: true, using: :btree

  create_table "userhost", force: true do |t|
    t.string    "host"
    t.string    "clientip",  limit: 20
    t.timestamp "writetime"
    t.integer   "processed", limit: 1,  default: 0
  end

  create_table "userruleship", force: true do |t|
    t.integer  "user_id"
    t.integer  "rule_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "userruleship", ["user_id", "rule_id"], name: "index_userruleship_on_user_id_and_rule_id", unique: true, using: :btree

end
