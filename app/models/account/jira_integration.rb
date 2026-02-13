class Account::JiraIntegration < ApplicationRecord
  belongs_to :account

  encrypts :api_token

  validates :site_url, :email, :api_token, :project_key, presence: true

  normalizes :site_url, with: ->(url) { url.strip.chomp("/") }
  normalizes :email, with: ->(email) { email.strip }
  normalizes :project_key, with: ->(key) { key.strip.upcase }

  def configured?
    persisted? && site_url.present? && email.present? && api_token.present? && project_key.present?
  end

  def create_issue(summary:, description:)
    response = connection.post("/rest/api/3/issue") do |req|
      req.body = {
        fields: {
          project: { key: project_key },
          summary: summary,
          description: {
            type: "doc",
            version: 1,
            content: [
              { type: "paragraph", content: [ { type: "text", text: description } ] }
            ]
          },
          issuetype: { name: issue_type }
        }
      }
    end

    unless response.success?
      raise Faraday::Error, "Jira API error (#{response.status}): #{response.body}"
    end

    response
  end

  def test_connection
    response = connection.get("/rest/api/3/myself")

    if response.success?
      { success: true }
    else
      { success: false, error: "HTTP #{response.status}: #{response.body}" }
    end
  rescue Faraday::Error => e
    { success: false, error: e.message }
  end

  private
    def connection
      Faraday.new(url: site_url) do |f|
        f.request :json
        f.response :json
        f.request :authorization, :basic, email, api_token
      end
    end
end
