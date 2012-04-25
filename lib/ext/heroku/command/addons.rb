module Heroku::Command

  # manage addon resources
  #
  class Addons < Base

    # addons:add ADDON | NAME
    #
    # install an addon
    #
    # --config CONFIG  # a non-default config var to use for attaching a resource
    #
    def add
      argument = args.first
      params = if config_var = extract_option('--config')
        { :config_var => config_var }
      else
        {}
      end

      if addon_info = heroku.addon(argument) rescue nil
        if addon_info["attachable"] == false
          if config_var
            raise CommandFailed.new("--config is not a valid option for non-attachable addons")
          end
          # new non-attachable resource
          configure_addon('Adding') do |addon, config|
            heroku.install_addon(app, addon, config)
          end
        else
          # new attachable resource
          resource_info = nil
          action("Adding #{argument} to #{app}") do
            resource_info = heroku.add_resource(app, argument, params)
          end
          attachment = resource_info["attachments"].detect {|attachment| attachment["app"]["name"] == app}
          display("#{resource_info["name"]} assigned to #{attachment["config_var"]}")
        end
      elsif resource_info = heroku.get_resource(argument) rescue nil
        # existing attachable resource
        attachment_info = nil
        action("Adding #{argument} to #{app}") do
          attachment_info = heroku.add_attachment(app, argument, params)
        end
        display("#{argument} assigned to #{attachment_info["config_var"]}")
      else
        display("Addon or resource not found")
      end
    end

    # addons
    #
    # list installed addons
    #
    def index
      installed = heroku.installed_addons(app)
      attachments = heroku.get_attachments(app)

      if attachments.empty? && installed.empty?
        display "No addons installed"
      else

      resources = Hash.new {|hash,key| hash[key] = {}}
      attachments.each do |attachment|
        resource = attachment["resource"]["name"]
        resources[resource]["Billing App"] = attachment["app"]["name"]
        resources[resource]["Config"] ||= []
        resources[resource]["Config"] << attachment["config_var"]
        type = attachment["resource"]["type"]
        resources[resource]["Type"] = type
        installed.reject! {|addon| addon["name"] == type}
      end
      resources.map {|resource, data| data["Config"] = data["Config"].join(", ")}

      resources.keys.sort.each do |resource_name|
        display("=== #{resource_name}")
        resource_data = resources[resource_name]
        max_length = resource_data.keys.map {|key| key.length}.max + 2
        resource_data.keys.sort.each do |key|
          display("#{key}:".ljust(max_length), false)
          display(resource_data[key])
        end
      end

      available, pending = installed.partition { |a| a['configured'] }

      unless available.empty?
        display("=== Other Addons")
        available.map do |a|
            if a['attachment_name']
              a['name'] + ' => ' + a['attachment_name']
            else
              a['name']
            end
          end.sort.each do |addon|
            display(addon)
          end
        end

        unless pending.empty?
          display "\n--- not configured ---"
          pending.map { |a| a['name'] }.sort.each do |addon|
            display addon.ljust(24) + "http://#{heroku.host}/myapps/#{app}/addons/#{addon}"
          end
        end
      end
    end

    # addons:info ADDON
    #
    # list info for an addon
    #
    def info
      argument = args.shift
      raise CommandFailed.new("Missing add-on name") if argument.nil?
      if resource_info = heroku.get_resource(argument) rescue nil
        resource = {}
        resource_info["attachments"].each do |attachment|
          resource["Billing App"] = attachment["app"]["name"]
          resource["Config"] ||= []
          resource["Config"] << attachment["config_var"]
          resource["Type"] = resource_info["type"]
        end
        resource["Config"] = resource["Config"].join(", ")

        display("=== #{argument}")
        max_length = resource.keys.map {|key| key.length}.max + 2
        resource.keys.sort.each do |key|
          display("#{key}: ".ljust(max_length), false)
          display(resource[key])
        end
      else
        addon_info = heroku.addon(argument)
        display("=== #{addon}")
        max_length = addon_info.keys.map {|key| key.length}.max + 2
        addon_info["price"] = if addon_info["price"]["cents"] == 0
          "free"
        else
          "$#{addon_info["price"]["cents"] / 100.0}/#{addon_info["price"]["unit"]}"
        end
        addon_info.keys.sort.each do |key|
          next unless addon_info[key]
          title_cased = key.split(" ").map {|word| word[0...1].upcase + word[1..-1]}.join(" ")
          display("#{title_cased}: ".ljust(max_length), false)
          display(addon_info[key])
        end
      end
    end

    # addons:remove ADDON | NAME
    #
    # uninstall an addon
    #
    # --config CONFIG  # a non-default config var to remove a resource from
    #
    def remove
      return unless confirm_command
      options[:confirm] ||= app

      args.each do |name|
        if resource_info = heroku.get_resource(name) rescue nil
          if resource_info["attachments"].length > 0
            attachments = resource_info["attachments"].select {|attachment| attachment["app"]["name"] == app}
            if attachments.length > 1
              unless config_var = extract_option('--config')
                message = "#{name} matches:"
                attachments.each do |attachment|
                  message << "\n  #{attachment["config_var"]}"
                end
                message << "\nRun this command again with one of these and --config to continue."
                raise CommandFailed.new(message)
              end

              action("Removing #{name} from #{app}") do
                heroku.delete_attachment(app, config_var)
              end
              display("#{name} no longer assigned to #{config_var}")
            else
              attachment = resource_info["attachments"].first
              action("Removing #{name} from #{app}") do
                heroku.delete_resource(name)
              end
              display("#{name} no longer assigned to #{attachment["config_var"]}")
            end
          else
            attachment = resource_info["attachments"].first
            action("Removing #{name} from #{app}") do
              heroku.delete_resource(name)
            end
            display("#{name} no longer assigned to #{attachment["config_var"]}")
          end
        elsif addon_info = heroku.addon(name) rescue nil
          # non resource
          messages = nil
          action("Removing #{name} from #{app}") do
            messages = addon_run { heroku.uninstall_addon(app, name, :confirm => options[:confirm]) }
          end
          output messages[:attachment] if messages[:attachment]
          output messages[:message]
        else
          display("Addon or resource not found")
        end
      end
    end

  end

end
