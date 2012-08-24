module Heroku::Helpers::HerokuPostgresql

  def hpg_databases
    @hpg_databases ||= begin
      databases = {}

      # traditional resources
      app_config_vars.each do |name, url|
        if name =~ /^(#{hpg_addon_prefix}\w+)_URL$/
          databases[$1] = url
        elsif name == 'SHARED_DATABASE_URL'
          databases['SHARED_DATABASE'] = url
        end
      end

      # attachable resources
      heroku.get_attachments(app).each do |attachment|
        if attachment['resource']['type'].split(':').first == hpg_addon_name
          config = attachment['config_var']
          databases[config.gsub(/_URL$/, '')] = app_config_vars[config]
        end
      end

      databases
    end
  end

end
