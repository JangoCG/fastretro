# frozen_string_literal: true

module Retros
  class ExportsController < ApplicationController
    before_action :set_retro

    def show
      respond_to do |format|
        format.csv do
          send_data generate_csv, filename: filename(:csv), type: "text/csv; charset=utf-8"
        end
        format.xlsx do
          send_data generate_xlsx, filename: filename(:xlsx), type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        end
      end
    end

    private

    def set_retro
      @retro = Current.account.retros.find(params[:retro_id])
    end

    def filename(extension)
      "#{@retro.name.parameterize}-#{Date.current}.#{extension}"
    end

    def feedbacks_data
      data = []

      @retro.column_definitions.each do |column|
        @retro.feedbacks.published.in_category(column["id"]).includes(:user, :votes).each do |feedback|
          data << [ column["name"], strip_html(feedback.content.to_plain_text), feedback.user.name, feedback.votes.size ]
        end
      end

      data
    end

    def actions_data
      @retro.actions.published.includes(:user).map do |action|
        [ strip_html(action.content.to_plain_text), action.user.name ]
      end
    end

    def generate_csv
      CSV.generate(headers: true) do |csv|
        csv << [ "Category", "Feedback", "Author", "Votes" ]
        feedbacks_data.each { |row| csv << row }

        csv << []
        csv << [ "Done", "Action Item", "Owner", "Notes" ]
        actions_data.each { |row| csv << [ "[ ]", row[0], row[1], "" ] }
      end
    end

    def generate_xlsx
      package = Axlsx::Package.new
      workbook = package.workbook

      # Styles
      header_style = workbook.styles.add_style(b: true, bg_color: "000000", fg_color: "FFFFFF", sz: 12)
      feedback_style = workbook.styles.add_style(bg_color: "F4F4F5")
      action_style = workbook.styles.add_style(bg_color: "EDE9FE")

      # Feedbacks sheet
      workbook.add_worksheet(name: "Feedbacks") do |sheet|
        sheet.add_row [ "Category", "Feedback", "Author", "Votes" ], style: header_style

        feedbacks_data.each do |row|
          sheet.add_row row, style: feedback_style
        end

        sheet.column_widths 15, 80, 20, 8
      end

      # Actions sheet
      workbook.add_worksheet(name: "Action Items") do |sheet|
        sheet.add_row [ "Done", "Action Item", "Owner", "Notes" ], style: header_style

        checkbox_style = workbook.styles.add_style(bg_color: "EDE9FE", alignment: { horizontal: :center })

        actions_data.each do |row|
          sheet.add_row [ "☐", row[0], row[1], "" ], style: [ checkbox_style, action_style, action_style, action_style ]
        end

        sheet.column_widths 8, 70, 20, 30
      end

      package.to_stream.read
    end

    def strip_html(text)
      ActionController::Base.helpers.strip_tags(text).gsub(/\s+/, " ").strip
    end
  end
end
