require "test_helper"
require_relative 'application_controller_test.rb'

class SongsControllerTest < ApplicationControllerTest

  # "index" action tests
  test "index should be retrieved successfully" do
    get :index
    assert_response :success
  end

  test "index should retrieve relevant keyword search results" do
    get :index, search: { value: "hand" }, format: :json, xhr: true

    songs_data = load_songs

    assert_includes(songs_data, songs(:hands_to_the_heaven))
    assert_includes(songs_data, songs(:glorious_day))
  end

  test "index should stack filters" do
    http_params = {
      search: { value: "forever" },
      tempo: "Medium",
      key: "B",
      format: :json,
      xhr: :true
    }

    get :index, http_params
    songs_data = load_songs

    # these songs almost match but have different keys
    assert(songs_data.exclude?(songs(:all_my_hope)))
    assert(songs_data.exclude?(songs(:ten_thousand_reasons)))
    assert(songs_data.exclude?(songs(:forever_reign)))

    assert_includes(songs_data, songs(:glorious_day))
  end

  # "new" action tests
  test "new song page should load successfully if logged in as praise member" do
    get_edit_privileges
    get :new
    assert_response :success
  end

  test "readers should be redirected to songs index if they try to access the new song page" do
    get :new
    assert_redirected_to songs_path
  end

  # "create" action tests
  test "should load the new song template when song creation unsuccessful" do
    get_edit_privileges
    post :create, song: {problem: true}
    assert_template :new
  end

  test "should show error messages when song creation unsuccessful" do
    get_edit_privileges
    post :create, song: {problem: true}
    assert_select ".song-errors", true, "Error messages did not appear when song creation failed"
  end

  test "submitting a valid song should result in a new song in the database with the same name" do
    get_edit_privileges
    assert_difference('Song.count', difference = 1) do
      post_new_song_form
    end
    assert_not_nil Song.find_by_name("New Song Just Posted")
  end

  test "after creating a new song should redirect to its show song page" do
    get_edit_privileges
    post_new_song_form
    assert_redirected_to song_path(assigns(:song))
  end

  test "should notify user appropriately when song created successfully" do
    get_edit_privileges
    post_new_song_form
    assert_not_nil flash[:success]
  end

  test "readers should be redirected to songs index if they try to create" do
    post_new_song_form
    assert_redirected_to songs_path
  end

  # "update" action tests
  test "updating a song should result in the song having a different name in the DB" do
    get_edit_privileges
    new_song_name = "Newer Song Just Updated"

    song = songs(:God_be_praised)
    song.name = new_song_name
    post :update, song: song.as_json, id: song.id

    updated_song = Song.find_by_name(new_song_name)
    assert_equal updated_song.id, song.id
  end

  test "after editing a song should redirect to its show song page" do
    get_edit_privileges
    song = songs(:God_be_praised)
    post :update, song: song.as_json, id: song.id
    assert_redirected_to song_path(song)
  end

  test "readers should be directed to songs index if they try to update a song" do
    song = songs(:God_be_praised)
    post :update, song: song.as_json, id: song.id
    assert_redirected_to songs_path
  end

  # "edit" action tests
  test "edit song page should load successfully if logged in as praise member" do
    get_edit_privileges
    get :edit, id: songs(:forever_reign).id
    assert_response :success
  end

  test "readers should be redirected to songs index if they try to access the edit song page" do
    get :edit, id: songs(:forever_reign).id
    assert_redirected_to songs_path
  end

  # "print" action tests
  test "the standard scan field should not appear if it is blank" do
    get :print, id: songs(:relevant_1).id
    assert_select ".standard-scan", false, "Standard scan should not appear if it is blank"
  end

  private
  def load_songs
    JSON.parse(@response.body)["data"].map do |s|
      s.delete('relevance')
      Song.new(s)
    end
  end

  def post_new_song_form
    post :create, song: {
      name: "New Song Just Posted",
      key: "E",
      artist: "New Song Artist",
      tempo: "Fast",
      chord_sheet: "New Song Chords"
    }
  end

end
