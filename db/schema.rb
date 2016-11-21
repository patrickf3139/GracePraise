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

ActiveRecord::Schema.define(version: 20161120224823) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "btree_gin"

  create_table "song_tags", force: :cascade do |t|
    t.integer  "song_id"
    t.integer  "tag_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "song_tags", ["song_id"], name: "index_song_tags_on_song_id", using: :btree
  add_index "song_tags", ["tag_id"], name: "index_song_tags_on_tag_id", using: :btree

  create_table "songs", force: :cascade do |t|
    t.string   "name",          null: false
    t.string   "key",           null: false
    t.string   "artist"
    t.text     "chord_sheet",   null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "tempo",         null: false
    t.text     "lyrics",        null: false
    t.text     "standard_scan"
  end

  add_index "songs", ["artist"], name: "index_songs_on_artist", using: :gin
  add_index "songs", ["lyrics"], name: "index_songs_on_lyrics", using: :gin
  add_index "songs", ["name"], name: "index_songs_on_name", using: :gin

  create_table "tags", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
