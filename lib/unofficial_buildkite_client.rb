require "unofficial_buildkite_client/version"
require "unofficial_buildkite_client/http_client"
require "logger"

class UnofficialBuildkiteClient
  class Error < StandardError; end

  GRAPHQL_ENDPOINT = "https://graphql.buildkite.com/v1"
  INTERNAL_API_HOST = "https://buildkite.com"

  def initialize(access_token: ENV["BUILDKITE_ACCESS_TOKEN"], org_slug: nil, pipeline_slug: nil, logger: Logger.new(STDERR))
    @client = HttpClient.new(authorization_header: "Bearer #{access_token}", logger: logger)
    @org_slug = org_slug
    @pipeline_slug = pipeline_slug
  end

  def fetch_builds(org_slug: @org_slug, pipeline_slug: @pipeline_slug, created_at_from: nil, first: nil, last: nil, state: nil)
    variables = {slug: "#{org_slug}/#{pipeline_slug}", createdAtFrom: created_at_from, first: first, last: last, state: state}

    post_graphql(<<~GRAPHQL, variables: variables).dig(:data, :pipeline, :builds, :edges).map {|b| b[:node] }
      query ($createdAtFrom: DateTime, $slug: ID!, $first: Int, $last: Int, $state: [BuildStates!]) {
        pipeline(slug: $slug) {
          builds(
            first: $first
            last: $last
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

  def fetch_artifacts(org_slug: @org_slug, pipeline_slug: @pipeline_slug, build_number:, job_id:)
    @client.request(:get, "#{INTERNAL_API_HOST}/organizations/#{org_slug}/pipelines/#{pipeline_slug}/builds/#{build_number}/jobs/#{job_id}/artifacts")
  end

  def fetch_artifact(org_slug: @org_slug, pipeline_slug: @pipeline_slug, build_number:, job_id:, artifact_id:)
    @client.request(:get, "#{INTERNAL_API_HOST}/organizations/#{org_slug}/pipelines/#{pipeline_slug}/builds/#{build_number}/jobs/#{job_id}/artifacts/#{artifact_id}", json: false)
  end

  def fetch_log(org_slug: @org_slug, pipeline_slug: @pipeline_slug, build_number:, job_id:)
    @client.request(:get, "#{INTERNAL_API_HOST}/organizations/#{org_slug}/pipelines/#{pipeline_slug}/builds/#{build_number}/jobs/#{job_id}/log")
  end

  def post_graphql(query, variables: {})
    @client.request(:post, GRAPHQL_ENDPOINT, params: {query: query, variables: variables})
  end
end
