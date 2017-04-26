module ApplicationHelper
  def date_f(date)
    timeago_tag date, lang: :ko, limit: 3.days.ago
  end

  def screened(model, attr)
    if model.screened?
      content_tag(:span, '신고로 인해 가려진 글입니다', class: "text-muted")
    else
      if block_given?
        capture_haml do
          yield model.send(attr)
        end
      else
        model.send(attr)
      end
    end
  end

  def smart_format(text, html_options = {}, options = {})
    parsed_text = simple_format(h(text), html_options, options).to_str
    raw(auto_link(parsed_text,
      html: {class: 'auto_link', target: '_blank'},
      link: :urls,
      sanitize: false))
  end

  def asset_data_base64(path)
    content, content_type = parse_asset(path)
    base64 = Base64.encode64(content).gsub(/\s+/, "")
    "data:#{content_type};base64,#{Rack::Utils.escape(base64)}"
  end

  def parse_asset(path)
    if Rails.application.assets
      asset = Rails.application.assets.find_asset(path)
      throw "Could not find asset '#{path}'" if asset.nil?
      return asset.to_s, asset.content_type
    else
      name = Rails.application.assets_manifest.assets[path]
      throw "Could not find asset '#{path}'" if name.nil?
      content_type = MIME::Types.type_for(name).first.content_type
      content = open(File.join(Rails.public_path, 'assets', name)).read
      return content, content_type
    end
  end

  def is_redactorable?
    !browser.device.mobile? and !browser.device.tablet?
  end

  def hide_gnb_and_footer?
    ( params[:controller] == 'projects' && params[:action] == 'show' ) ||
    ( params[:controller] == 'projects' && params[:action] == 'events' ) ||
    ( params[:controller] == 'polls' && params[:action] == 'show' ) ||
    ( params[:controller] == 'surveys' && params[:action] == 'show' ) ||
    ( params[:controller] == 'petitions' && params[:action] == 'show' ) ||
    ( params[:controller] == 'wikis' && params[:action] == 'show' ) ||
    ( params[:controller] == 'discussions' && params[:action] == 'show' ) ||
    ( params[:controller] == 'events' && params[:action] == 'show' ) ||
    ( params[:controller] == 'speeches' && params[:action] == 'index' )
  end

  def excerpt(text, options = {})
    options[:length] = 130 unless options.has_key?(:length)
    truncate((strip_tags(text).try(:html_safe)), options)
  end

  def fill_in(template, data)
    return if template.blank?
    template.gsub(/\{\{(\w+)\}\}/) { data[$1.to_sym] }
  end

  def survey_remain_time(survey)
    return '계속' if survey.duration <= 0
    distance_of_time_in_words_to_now(survey.created_at + survey.duration.days)
  end

  ALLOWED_EXTENSIONS = %w(txt doc docx xls xlsx ppt pptx bmp gif jpeg jpg png bz2 dmg gz gzip iso rar tar tgz zip)
  def file_type_icon(content_type)
    mime_type = MIME::Types[content_type].first
    extension = mime_type.try(:preferred_extension)
    extension = 'txt' unless ALLOWED_EXTENSIONS.include?(extension)
    content_tag(:i, nil, class: ["fa", "fa-file-#{extension}-o"])
  end

  def smart_truncate_html(text, options = {})
    max_length = options[:length] || 3
    HTML_Truncator.truncate(text, max_length, options)
  end
end
