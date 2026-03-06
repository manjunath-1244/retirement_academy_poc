module ApplicationHelper
  def frontpage_header_text
    FrontpageContent.first&.header_text.presence || "Retirement Academy"
  end
end
