# A Ruby class to call the Heroku REST API.  You might use this if you want to
# manage your Heroku apps from within a Ruby program, such as Capistrano.
#
# Example:
#
#   require 'heroku'
#   heroku = Heroku::Client.new('me@example.com', 'mypass')
#   heroku.create('myapp')
#
class Heroku::Client

  def addon(addon)
    json_decode(get("/addons/#{addon}"))
  end

  # attachments

  def add_attachment(app, resource, options = {})
    json_decode(post("/apps/#{app}/attachments", options.merge(:resource_name => resource)))
  end

  def delete_attachment(app, config_var)
    json_decode(delete("/apps/#{app}/attachments/#{config_var}"))
  end

  def get_attachments(app)
    json_decode(get("/apps/#{app}/attachments"))
  end

  # resources

  def add_resource(app, resource, options = {})
    json_decode(post("/resources", options.merge(:app_name => app, :addon => resource)))
  end

  def delete_resource(resource)
    json_decode(delete("/resources/#{resource}"))
  end

  def get_resource(resource)
    json_decode(get("/resources/#{resource}"))
  end

end
