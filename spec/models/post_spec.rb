require 'rails_helper'

RSpec.describe Post, type: :model do
  describe 'Validations' do
    it 'Validate presence of required fields' do
      should validate_presence_of(:title)
      should validate_presence_of(:content)
      should validate_presence_of(:user_id)
    end
  end
end

RSpec.describe Post, type: :request do
  describe "GET /post" do
    before { get '/posts' }

    it 'Should return a empty list of posts' do
      payload = JSON.parse(response.body)
      expect(payload).to be_empty
      expect(response).to have_http_status(200)
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