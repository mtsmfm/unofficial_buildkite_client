require "unofficial_buildkite_client/version"
require "unofficial_buildkite_client/json_api_client"

class UnofficialBuildkiteClient
  class Error < StandardError; end

  class << self
    def logger=(logger)
      @logger = logger
    end

    def logger
      @logger
    end
  end

  self.logger = Logger.new(STDERR)

  GRAPHQL_ENDPOINT = "https://graphql.buildkite.com/v1"
  INTERNAL_API_HOST = "https://buildkite.com"

  def initialize(access_token: ENV["BUILDKITE_ACCESS_TOKEN"], org_slug: nil, pipeline_slug: nil)
    @client = JsonApiClient.new(authorization_header: "Bearer #{access_token}")
    @org_slug = org_slug
    @pipeline_slug = pipeline_slug
  end

  def fetch_builds(org_slug: @org_slug, pipeline_slug: @pipeline_slug, created_at_from:, first:, state:)
    variables = {slug: "#{org_slug}/#{pipeline_slug}", createdAtFrom: created_at_from, first: first, state: state}

    post_graphql(<<~GRAPHQL, variables: variables).dig(:data, :pipeline, :builds, :edges).map {|b| b[:node] }
      query ($createdAtFrom: DateTime, $slug: ID!, $first: Int, $state: [BuildStates!]) {
        pipeline(slug: $slug) {
          builds(
            first: $first
            state: $state
            createdAtFrom: $createdAtFrom
          ) {
            edges {
              node {
                branch
                canceledAt
                commit
                createdAt
                env
                finishedAt
                id
                message
                number
                scheduledAt
                source {
                  name
                }
                startedAt
                state
                url
                uuid
              }
            }
          }
        }
      }
    GRAPHQL
  end

  def fetch_build(org_slug: @org_slug, pipeline_slug: @pipeline_slug, number:)
    @client.request(:get, "#{INTERNAL_API_HOST}/#{org_slug}/#{pipeline_slug}/builds/#{number}")
  end

  def fetch_log(org_slug: @org_slug, pipeline_slug: @pipeline_slug, build_number:, job_id:)
    @client.request(:get, "#{INTERNAL_API_HOST}/organizations/#{org_slug}/pipelines/#{pipeline_slug}/builds/#{build_number}/jobs/#{job_id}/log")
  end

  def post_graphql(query, variables: {})
    @client.request(:post, GRAPHQL_ENDPOINT, params: {query: query, variables: variables})
  end
end
