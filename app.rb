# This file contains the main code for the app
require 'sinatra'
require 'octokit'
require 'dotenv/load' # load environment variable from .env

# GitHub credentials
GITHUB_USERNAME = 'laetitiastuder'
REPOS = {
  'RailsBlog' => 'laetitiastuder',
  'QuoteGenerator' => 'laetitiastuder'
}
# Set up Octokit client with my access token
Octokit.configure do |c|
  c.access_token = ENV['GITHUB_TOKEN']
end

# Route to display PRs
get '/' do
  'Hello, Sinatra!'
end

helpers do
  def display_avatar(username)
    user_info = Octokit.user(username)
    if user_info.avatar_url
      '<img src="' + user_info.avatar_url + '" alt="Avatar" width="50px" height="50px" border-radius="50%" object-fit="cover">'
    else
      'No avatar available'
    end
  end

  def format_datetime(datetime)
    datetime.strftime('%d/%m/%Y %H:%M')
  end
end

get '/pull_requests' do
  @all_pull_requests = []

  REPOS.each do |repo_name, repo_user|
    pull_requests = Octokit.pull_requests("#{repo_user}/#{repo_name}", state: 'all')
    @all_pull_requests.concat(pull_requests)
  end
  # @pull_requests = Octokit.pull_requests("#{REPO_OWNER}/#{REPO_NAME}")
  # @pull_requests = Octokit.pull_requests(REPOS)
  # print @pull_requests
  erb :pull_requests
end

client = Octokit::Client.new(:access_token => ENV['GITHUB_TOKEN'])

# get '/user' do
#   @user = client.user
#   @repos = client.repos({}, query: {type: 'owner', sort: 'asc'})
#   @repos_with_prs = {}

#   @repos.each do |repo|
#     @repos_with_prs[repo.full_name] = client.pull_requests(repo.full_name)
#   end
#   # print @repos
#   # @pr = Octokit.pull_requests(@repos)
#   # print "hello"
#   # print "**********#{@pr}"
#   erb :user
# end

get '/repo' do
  @user = client.user
  @repos = client.repos(GITHUB_USERNAME, per_page: 100)
  # print "repos11: #{@repos}"
  @repos_with_prs = {}

  @repos.each do |repo|
    @repos_with_prs[repo.full_name] = client.pull_requests(repo.full_name,:state => 'all')
  end
  print @repos_with_prs
  erb :repo
end

