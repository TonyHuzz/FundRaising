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

ActiveRecord::Schema.define(version: 2023_04_23_132700) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "pledge_id"
    t.string "merchant_order_no"
    t.integer "end_price"
    t.integer "status", default: 0, null: false
    t.datetime "paid_date"
    t.datetime "unpaid_payment_expire_date"
    t.integer "transaction_service_provider"
    t.string "third_party_payment_id"
    t.string "time_stamp"
    t.integer "payment_type"
    t.string "bank_code"
    t.string "code_no"
    t.string "cvs_code"
    t.string "barcode_1"
    t.string "barcode_2"
    t.string "barcode_3"
    t.string "buyer_account_code"
    t.string "payment_type_charging_fee"
    t.string "credit_card_number"
    t.string "auth"
    t.string "inst"
    t.string "inst_first"
    t.string "inst_each"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pledge_id"], name: "index_payments_on_pledge_id"
  end

  create_table "pledges", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "project_support_id"
    t.string "project_name"
    t.datetime "issue_date"
    t.integer "status", default: 0, null: false
    t.string "support_name"
    t.integer "support_price"
    t.integer "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "merchantOrderNo"
    t.index ["project_support_id"], name: "index_pledges_on_project_support_id"
    t.index ["user_id"], name: "index_pledges_on_user_id"
  end

  create_table "project_owners", force: :cascade do |t|
    t.bigint "user_id"
    t.text "description"
    t.string "cover_image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_project_owners_on_user_id"
  end

  create_table "project_supports", force: :cascade do |t|
    t.bigint "project_id"
    t.string "name"
    t.text "description"
    t.integer "price"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_project_supports_on_project_id"
  end

  create_table "projects", force: :cascade do |t|
    t.bigint "project_owner_id"
    t.bigint "category_id"
    t.string "name"
    t.string "brief"
    t.text "description"
    t.integer "goal"
    t.datetime "due_date"
    t.string "ad_url"
    t.string "cover_image"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_projects_on_category_id"
    t.index ["project_owner_id"], name: "index_projects_on_project_owner_id"
  end

  create_table "slider_items", force: :cascade do |t|
    t.string "title"
    t.string "url"
    t.text "description"
    t.string "cover_image"
    t.integer "order_index", default: 10, null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_index"], name: "index_slider_items_on_order_index"
    t.index ["status"], name: "index_slider_items_on_status"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "name"
    t.string "avatar"
    t.string "provider"
    t.string "uid"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
