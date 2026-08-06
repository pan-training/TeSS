# The helper for Spaces classes
module SpacesHelper
  def spaces_info
    I18n.t('info.spaces.description')
  end

  def space_feature_options
    Space::FEATURES.select do |f|
      TeSS::Config.feature[f]
    end.map do |f|
      [t("features.#{f}.short"), f]
    end
  end

  def omniauth_providers_for_space(space = current_space)
    host = space&.host || TeSS::Config.base_uri.host

    Devise.omniauth_configs.select do |_provider, config|
      default_redirect_uri = config.options.dig(:client_options, :redirect_uri)
      extra_redirect_uris = Array(config.options[:extra_redirect_uris])

      [default_redirect_uri, *extra_redirect_uris].compact_blank.any? do |uri|
        URI.parse(uri).host == host
      rescue URI::InvalidURIError
        false
      end
    end
  end

  def space_supports_omniauth?(space = current_space)
    omniauth_providers_for_space(space).any?
  end
end
