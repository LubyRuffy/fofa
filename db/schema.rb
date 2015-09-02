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

ActiveRecord::Schema.define(version: 20150902094827) do

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace",     limit: 255
    t.text     "body",          limit: 65535
    t.string   "resource_id",   limit: 255,   null: false
    t.string   "resource_type", limit: 255,   null: false
    t.integer  "author_id",     limit: 4
    t.string   "author_type",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "analysis_info", force: :cascade do |t|
    t.text "server_info",   limit: 65535
    t.text "cms_info",      limit: 65535
    t.text "cloudsec_info", limit: 65535
    t.date "writedate"
  end

  add_index "analysis_info", ["writedate"], name: "writedate", unique: true, using: :btree

  create_table "apicall", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.string   "query",      limit: 255
    t.string   "action",     limit: 255
    t.string   "ip",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "asset_domains", force: :cascade do |t|
    t.string   "domain",     limit: 255
    t.integer  "target_id",  limit: 4
    t.text     "memo",       limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.boolean  "useradd"
  end

  add_index "asset_domains", ["target_id", "domain"], name: "asset_domains_target_index", unique: true, using: :btree

  create_table "asset_entrances", force: :cascade do |t|
    t.integer "target_id",     limit: 4
    t.string  "entrance_type", limit: 255
    t.string  "value",         limit: 255
    t.text    "memo",          limit: 65535
  end

  add_index "asset_entrances", ["target_id", "entrance_type", "value"], name: "asset_entrances_type_value_index", unique: true, using: :btree

  create_table "asset_hosts", force: :cascade do |t|
    t.string   "host",       limit: 255
    t.integer  "target_id",  limit: 4
    t.text     "memo",       limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "domain",     limit: 255
    t.boolean  "useradd"
  end

  add_index "asset_hosts", ["target_id", "host"], name: "asset_hosts_host_index", unique: true, using: :btree

  create_table "asset_ips", force: :cascade do |t|
    t.string   "ip",         limit: 255
    t.integer  "target_id",  limit: 4
    t.text     "memo",       limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "domain",     limit: 255
    t.string   "ipnet",      limit: 255
    t.boolean  "useradd"
  end

  add_index "asset_ips", ["target_id", "ip"], name: "asset_ips_ip_index", unique: true, using: :btree

  create_table "asset_persons", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "email",       limit: 255
    t.integer  "target_id",   limit: 4
    t.text     "memo",        limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "domain",      limit: 255
    t.text     "otheremails", limit: 65535
    t.text     "alias",       limit: 65535
    t.boolean  "useradd"
  end

  add_index "asset_persons", ["target_id", "name"], name: "asset_persons_name_index", unique: true, using: :btree

  create_table "badges_sashes", force: :cascade do |t|
    t.integer  "badge_id",      limit: 4
    t.integer  "sash_id",       limit: 4
    t.boolean  "notified_user",           default: false
    t.datetime "created_at"
  end

  add_index "badges_sashes", ["badge_id", "sash_id"], name: "index_badges_sashes_on_badge_id_and_sash_id", using: :btree
  add_index "badges_sashes", ["badge_id"], name: "index_badges_sashes_on_badge_id", using: :btree
  add_index "badges_sashes", ["sash_id"], name: "index_badges_sashes_on_sash_id", using: :btree

  create_table "category", force: :cascade do |t|
    t.string   "title",      limit: 255
    t.integer  "user_id",    limit: 4
    t.boolean  "published"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "category_rule", force: :cascade do |t|
    t.integer  "rule_id",     limit: 4
    t.integer  "category_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "category_rule", ["category_id", "rule_id"], name: "index_rule_on_category_rule", unique: true, using: :btree

  create_table "charts", force: :cascade do |t|
    t.integer  "rule_id",    limit: 4
    t.integer  "value",      limit: 4
    t.date     "writedate"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "exploits", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "description", limit: 255
    t.string   "filename",    limit: 255
    t.string   "author",      limit: 255
    t.string   "product",     limit: 255
    t.string   "homepage",    limit: 255
    t.string   "references",  limit: 255
    t.string   "fofaquery",   limit: 255
    t.text     "content",     limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "exploits", ["filename"], name: "index_exploits_on_filename", unique: true, using: :btree

  create_table "icp", primary_key: "ID", force: :cascade do |t|
    t.string  "DWMC",     limit: 255
    t.integer "ZTID",     limit: 8
    t.string  "DWXZ",     limit: 512
    t.string  "ZT_BAXH",  limit: 255
    t.integer "WZID",     limit: 8
    t.string  "WZMC",     limit: 255
    t.string  "WZFZR",    limit: 255
    t.string  "SITE_URL", limit: 512
    t.string  "YM",       limit: 255
    t.string  "WZ_BAXH",  limit: 255
    t.date    "SHSJ"
    t.string  "NRLX",     limit: 512
    t.string  "ZJLX",     limit: 255
    t.string  "ZJHM",     limit: 255
    t.string  "SHENGID",  limit: 255
    t.string  "SHIID",    limit: 255
    t.string  "XIANID",   limit: 255
    t.string  "XXDZ",     limit: 512
    t.string  "YMID",     limit: 255
  end

  add_index "icp", ["DWMC"], name: "DWMC", using: :btree
  add_index "icp", ["YM"], name: "YM", using: :btree
  add_index "icp", ["ZJHM"], name: "ZJHM", using: :btree

  create_table "merit_actions", force: :cascade do |t|
    t.integer  "user_id",       limit: 4
    t.string   "action_method", limit: 255
    t.integer  "action_value",  limit: 4
    t.boolean  "had_errors",                  default: false
    t.string   "target_model",  limit: 255
    t.integer  "target_id",     limit: 4
    t.text     "target_data",   limit: 65535
    t.boolean  "processed",                   default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "merit_activity_logs", force: :cascade do |t|
    t.integer  "action_id",           limit: 4
    t.string   "related_change_type", limit: 255
    t.integer  "related_change_id",   limit: 4
    t.string   "description",         limit: 255
    t.datetime "created_at"
  end

  create_table "merit_score_points", force: :cascade do |t|
    t.integer  "score_id",   limit: 4
    t.integer  "num_points", limit: 4,   default: 0
    t.string   "log",        limit: 255
    t.datetime "created_at"
  end

  create_table "merit_scores", force: :cascade do |t|
    t.integer "sash_id",  limit: 4
    t.string  "category", limit: 255, default: "default"
  end

  create_table "rootdomain", primary_key: "did", force: :cascade do |t|
    t.string   "domain",        limit: 255,   null: false
    t.string   "telephone",     limit: 50
    t.string   "email",         limit: 200
    t.text     "whois",         limit: 65535
    t.string   "whois_com",     limit: 255
    t.text     "ns_info",       limit: 65535
    t.datetime "lastchecktime"
  end

  add_index "rootdomain", ["domain"], name: "idx_rootdomain_1", using: :btree
  add_index "rootdomain", ["email"], name: "idx_2", using: :btree
  add_index "rootdomain", ["whois_com"], name: "idx_3", using: :btree

  create_table "rule", force: :cascade do |t|
    t.string   "product",      limit: 255
    t.string   "producturl",   limit: 255
    t.string   "rule",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",      limit: 4
    t.boolean  "published"
    t.integer  "from_rule_id", limit: 4
  end

  add_index "rule", ["product", "rule", "user_id"], name: "index_rule_on_product_and_rule", unique: true, length: {"product"=>50, "rule"=>nil, "user_id"=>nil}, using: :btree

  create_table "sashes", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sensitives", force: :cascade do |t|
    t.string   "reference",  limit: 255
    t.text     "content",    limit: 65535
    t.integer  "user_id",    limit: 4
    t.text     "memo",       limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "sph_counter", primary_key: "counter_id", force: :cascade do |t|
    t.integer  "max_id",       limit: 8,               null: false
    t.integer  "min_id",       limit: 4,  default: 1,  null: false
    t.string   "index_name",   limit: 32, default: "", null: false
    t.datetime "last_updated",                         null: false
  end

  add_index "sph_counter", ["index_name"], name: "index_name", using: :btree

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id",        limit: 4
    t.integer  "taggable_id",   limit: 4
    t.string   "taggable_type", limit: 255
    t.integer  "tagger_id",     limit: 4
    t.string   "tagger_type",   limit: 255
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name",           limit: 255
    t.integer "taggings_count", limit: 4,   default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "targets", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "website",    limit: 255
    t.text     "memo",       limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "targets", ["name"], name: "targets_name", using: :btree

  create_table "user", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username",               limit: 255
    t.string   "avatar_file_name",       limit: 255
    t.string   "avatar_content_type",    limit: 255
    t.integer  "avatar_file_size",       limit: 4
    t.datetime "avatar_updated_at"
    t.boolean  "isadmin"
    t.string   "key",                    limit: 255
    t.integer  "sash_id",                limit: 4
    t.integer  "level",                  limit: 4,   default: 0
    t.datetime "duration"
  end

  add_index "user", ["email"], name: "index_user_on_email", unique: true, using: :btree
  add_index "user", ["reset_password_token"], name: "index_user_on_reset_password_token", unique: true, using: :btree
  add_index "user", ["username"], name: "index_user_on_username", unique: true, using: :btree

  create_table "userhost", force: :cascade do |t|
    t.string   "host",      limit: 255
    t.string   "clientip",  limit: 20
    t.datetime "writetime"
    t.integer  "processed", limit: 1,   default: 0
    t.integer  "user_id",   limit: 4
  end

  create_table "users_targets", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "target_id",  limit: 4
    t.string   "user_type",  limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "users_targets", ["target_id", "user_id"], name: "users_targets_index", unique: true, using: :btree

end
