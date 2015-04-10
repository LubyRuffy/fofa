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

ActiveRecord::Schema.define(version: 20141109112524) do

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

  create_table "apicall", force: true do |t|
    t.integer  "user_id"
    t.string   "query"
    t.string   "action"
    t.string   "ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "autoloading", force: true do |t|
    t.boolean "in_use"
    t.integer "command_id", null: false
  end

  add_index "autoloading", ["command_id"], name: "index_autoloading_command", using: :btree

  create_table "badges_sashes", force: true do |t|
    t.integer  "badge_id"
    t.integer  "sash_id"
    t.boolean  "notified_user", default: false
    t.datetime "created_at"
  end

  add_index "badges_sashes", ["badge_id", "sash_id"], name: "index_badges_sashes_on_badge_id_and_sash_id", using: :btree
  add_index "badges_sashes", ["badge_id"], name: "index_badges_sashes_on_badge_id", using: :btree
  add_index "badges_sashes", ["sash_id"], name: "index_badges_sashes_on_sash_id", using: :btree

  create_table "category", force: true do |t|
    t.string   "title"
    t.integer  "user_id"
    t.boolean  "published"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "category_rule", force: true do |t|
    t.integer  "rule_id"
    t.integer  "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "category_rule", ["category_id", "rule_id"], name: "index_rule_on_category_rule", unique: true, using: :btree

  create_table "charts", force: true do |t|
    t.integer  "rule_id"
    t.integer  "value"
    t.date     "writedate"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "commands", force: true do |t|
    t.text    "data"
    t.string  "creationdate",      limit: 15
    t.text    "label"
    t.boolean "instructions_sent",            default: false
    t.integer "command_module_id",                            null: false
    t.integer "hooked_browser_id",                            null: false
  end

  add_index "commands", ["command_module_id"], name: "index_commands_command_module", using: :btree
  add_index "commands", ["hooked_browser_id"], name: "index_commands_hooked_browser", using: :btree

  create_table "core_browserdetails", id: false, force: true do |t|
    t.string "session_id",   null: false
    t.string "detail_key",   null: false
    t.text   "detail_value"
  end

  create_table "core_commandmodules", force: true do |t|
    t.text "name"
    t.text "path"
  end

  create_table "core_hookedbrowsers", force: true do |t|
    t.text    "session"
    t.text    "ip"
    t.string  "firstseen",   limit: 15
    t.string  "lastseen",    limit: 15
    t.text    "httpheaders"
    t.text    "domain"
    t.integer "port",                   default: 80
    t.integer "count"
    t.boolean "has_init",               default: false
    t.boolean "is_proxy",               default: false
  end

  create_table "core_logs", force: true do |t|
    t.text     "type"
    t.text     "event"
    t.datetime "date"
    t.text     "hooked_browser_id"
  end

  create_table "core_optioncache", force: true do |t|
    t.text "name"
    t.text "value"
  end

  create_table "core_results", force: true do |t|
    t.string  "date",              limit: 15
    t.text    "data"
    t.integer "hooked_browser_id",            null: false
    t.integer "command_id",                   null: false
  end

  add_index "core_results", ["command_id"], name: "index_core_results_command", using: :btree
  add_index "core_results", ["hooked_browser_id"], name: "index_core_results_hooked_browser", using: :btree

  create_table "error_host", force: true do |t|
    t.string   "host"
    t.datetime "lastupdatetime"
    t.text     "reason"
  end

  add_index "error_host", ["host"], name: "host", unique: true, using: :btree

  create_table "exploits", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "filename"
    t.string   "author"
    t.string   "product"
    t.string   "homepage"
    t.string   "references"
    t.string   "fofaquery"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "exploits", ["filename"], name: "index_exploits_on_filename", unique: true, using: :btree

  create_table "extension_adminui_users", force: true do |t|
    t.string "session_id"
    t.text   "ip"
  end

  create_table "extension_distributedengine_rules", force: true do |t|
    t.text    "data"
    t.boolean "enabled"
  end

  create_table "extension_dns_rules", force: true do |t|
    t.text "pattern",  null: false
    t.text "resource", null: false
    t.text "response", null: false
    t.text "callback", null: false
  end

  create_table "extension_requester_http", force: true do |t|
    t.text     "hooked_browser_id"
    t.text     "request"
    t.text     "allow_cross_domain"
    t.binary   "response_data",        limit: 16777215
    t.integer  "response_status_code"
    t.text     "response_status_text"
    t.text     "response_port_status"
    t.text     "response_headers"
    t.text     "method"
    t.text     "content_length"
    t.text     "domain"
    t.text     "port"
    t.text     "has_ran"
    t.text     "path"
    t.datetime "response_date"
    t.datetime "request_date"
  end

  create_table "extension_seng_interceptor", force: true do |t|
    t.text    "ip"
    t.text    "post_data"
    t.integer "webcloner_id", null: false
  end

  add_index "extension_seng_interceptor", ["webcloner_id"], name: "index_extension_seng_interceptor_webcloner", using: :btree

  create_table "extension_seng_webcloner", force: true do |t|
    t.text "uri"
    t.text "mount"
  end

  create_table "extension_xssrays_details", force: true do |t|
    t.text    "hooked_browser_id"
    t.text    "vector_name"
    t.text    "vector_method"
    t.text    "vector_poc"
    t.integer "xssraysscan_id",    null: false
  end

  add_index "extension_xssrays_details", ["xssraysscan_id"], name: "index_extension_xssrays_details_xssraysscan", using: :btree

  create_table "extension_xssrays_scans", force: true do |t|
    t.text     "hooked_browser_id"
    t.datetime "scan_start"
    t.datetime "scan_finish"
    t.text     "domain"
    t.text     "cross_domain"
    t.integer  "clean_timeout"
    t.boolean  "is_started",        default: false
    t.boolean  "is_finished",       default: false
  end

  create_table "icp", primary_key: "ID", force: true do |t|
    t.string  "DWMC"
    t.integer "ZTID",     limit: 8
    t.string  "DWXZ",     limit: 512
    t.string  "ZT_BAXH"
    t.integer "WZID",     limit: 8
    t.string  "WZMC"
    t.string  "WZFZR"
    t.string  "SITE_URL", limit: 512
    t.string  "YM"
    t.string  "WZ_BAXH"
    t.date    "SHSJ"
    t.string  "NRLX",     limit: 512
    t.string  "ZJLX"
    t.string  "ZJHM"
    t.string  "SHENGID"
    t.string  "SHIID"
    t.string  "XIANID"
    t.string  "XXDZ",     limit: 512
    t.string  "YMID"
  end

  add_index "icp", ["DWMC"], name: "DWMC", using: :btree
  add_index "icp", ["YM"], name: "YM", using: :btree
  add_index "icp", ["ZJHM"], name: "ZJHM", using: :btree

  create_table "merit_actions", force: true do |t|
    t.integer  "user_id"
    t.string   "action_method"
    t.integer  "action_value"
    t.boolean  "had_errors",    default: false
    t.string   "target_model"
    t.integer  "target_id"
    t.text     "target_data"
    t.boolean  "processed",     default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "merit_activity_logs", force: true do |t|
    t.integer  "action_id"
    t.string   "related_change_type"
    t.integer  "related_change_id"
    t.string   "description"
    t.datetime "created_at"
  end

  create_table "merit_score_points", force: true do |t|
    t.integer  "score_id"
    t.integer  "num_points", default: 0
    t.string   "log"
    t.datetime "created_at"
  end

  create_table "merit_scores", force: true do |t|
    t.integer "sash_id"
    t.string  "category", default: "default"
  end

  create_table "pointcrons", force: true do |t|
    t.integer  "user_id"
    t.string   "category"
    t.integer  "point"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rootdomain", primary_key: "did", force: true do |t|
    t.string   "domain",                    null: false
    t.string   "telephone",     limit: 50
    t.string   "email",         limit: 200
    t.text     "whois"
    t.string   "whois_com"
    t.text     "ns_info"
    t.datetime "lastchecktime"
  end

  add_index "rootdomain", ["domain"], name: "idx_rootdomain_1", using: :btree
  add_index "rootdomain", ["email"], name: "idx_2", using: :btree
  add_index "rootdomain", ["whois_com"], name: "idx_3", using: :btree

  create_table "rule", force: true do |t|
    t.string   "product"
    t.string   "producturl"
    t.string   "rule"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.boolean  "published"
    t.integer  "from_rule_id"
  end

  add_index "rule", ["product", "rule", "user_id"], name: "index_rule_on_product_and_rule", unique: true, length: {"product"=>50, "rule"=>nil, "user_id"=>nil}, using: :btree

  create_table "sashes", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sph_counter", primary_key: "counter_id", force: true do |t|
    t.integer  "max_id",       limit: 8,               null: false
    t.integer  "min_id",                  default: 1,  null: false
    t.string   "index_name",   limit: 32, default: "", null: false
    t.datetime "last_updated",                         null: false
  end

  add_index "sph_counter", ["index_name"], name: "index_name", using: :btree

  create_table "subdomain", force: true do |t|
    t.string    "host",           null: false
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
  add_index "subdomain", ["lastupdatetime"], name: "updatetime", using: :btree
  add_index "subdomain", ["reverse_domain"], name: "reverse_domain", using: :btree

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
    t.string   "key"
    t.integer  "sash_id"
    t.integer  "level",                  default: 0
    t.datetime "duration"
  end

  add_index "user", ["email"], name: "index_user_on_email", unique: true, using: :btree
  add_index "user", ["reset_password_token"], name: "index_user_on_reset_password_token", unique: true, using: :btree
  add_index "user", ["username"], name: "index_user_on_username", unique: true, using: :btree

  create_table "userhost", force: true do |t|
    t.string   "host"
    t.string   "clientip",  limit: 20
    t.datetime "writetime"
    t.integer  "processed", limit: 1,  default: 0
  end

end
