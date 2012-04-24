module Heroku::Command

  # manage addon resources
  #
  class Addons < Base

    # addons:info ADDON
    #
    # list info for an addon
    #
    def info
      addon = args.shift
      raise CommandFailed.new("Missing add-on name") if addon.nil?
      addon_info = heroku.addon(addon)
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

end
