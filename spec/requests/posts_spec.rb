require 'rails_helper'

RSpec.describe Post, type: :request do
  describe "GET /post" do
    it 'Should return a empty list of posts' do
      get '/posts'
      payload = JSON.parse(response.body)
      expect(payload).to be_empty
      expect(response).to have_http_status(200)
    end
    describe 'Search' do
      let!(:hi_rails) { create(:published_post, title: 'Hi rails') }
      let!(:hi_post) { create(:published_post, title: 'Hi Post') }
      let!(:whats_posts) { create(:published_post, title: 'Whats posts') }

      it 'Should filter posts by title' do
        get "/posts?search=Hi"
        payload = JSON.parse(response.body)

        expect(payload).to_not be_empty
        expect(payload.size).to eq(2)
        expect(payload.map {|i| i['id']}.sort).to  eq([hi_rails.id, hi_post.id].sort)
        expect(response).to have_http_status(200)

      end
    end
  end

  describe 'With data in the DB' do
    let!(:posts) { create_list(:post, 10, published: true) }
    before { get '/posts' }

    it "Should return all the published posts" do
      payload = JSON.parse(response.body)
      expect(payload.size).to eq(posts.size)
      expect(response).to have_http_status(200)
    end
    it 'Should return status code 200' do
      expect(response).to have_http_status(200)
    end
  end

  describe "GET /post/{id}" do

    # it 'Should return 404 status code' do
    #   get "/posts/#{0}"    
    #   expect(response).to have_http_status(404)
    # end

    let!(:post) { create(:post) }
    it 'Should return a post' do
      get "/posts/#{post.id}"

      payload = JSON.parse(response.body)
      expect(payload).not_to be_empty
      expect(payload['id']).to eq(post.id)
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST /posts' do
    let!(:user) {create(:user)}
    it "Should create a new post" do
      req_payload = {
        post: {
          title: "Title",
          content: "Content is a content",
          published: false,
          user_id: user.id
        }
      }

      post '/posts', params: req_payload

      payload = JSON.parse(response.body)

      expect(payload).to_not be_empty
      expect(payload['id']).to_not be_nil
      expect(payload['title']).to_not be_nil
      expect(payload['content']).to_not be_nil
      expect(payload['published']).to_not be_nil

      # Author
      expect(payload['author']['id']).to eq(user.id)
      expect(payload['author']['name']).to eq(user.name)
      expect(payload['author']['email']).to eq(user.email)

      expect(response).to have_http_status(:created)

    end

    it "Should return error message on invalid post" do
      req_payload = {
        post: {
          content: "Content is a content",
          published: false,
          user_id: user.id
        }
      }

      post '/posts', params: req_payload

      payload = JSON.parse(response.body)

      expect(payload).to_not be_empty
      expect(payload['error']).to_not be_empty
      expect(response).to have_http_status(:unprocessable_entity)

    end

  end

  describe 'PUT /posts' do
    let!(:article) {create(:post)}
    it "Should update a post" do
      req_payload = {
        post: {
          title: "New title",
          content: "Content is a content renewed",
          published: true,
        }
      }

      put "/posts/#{article.id}", params: req_payload

      payload = JSON.parse(response.body)

      expect(payload).to_not be_empty
      expect(payload['id']).to eq(article.id)
      expect(response).to have_http_status(:ok)

    end
    it "Should return error message on invalid post update" do
      req_payload = {
        post: {
          title: nil,
          content: nil,
          published: true,
        }
      }

      put "/posts/#{article.id}", params: req_payload

      payload = JSON.parse(response.body)

      expect(payload).to_not be_empty
      expect(payload['error']).to_not be_empty
      expect(response).to have_http_status(:unprocessable_entity)

    end
  end

end