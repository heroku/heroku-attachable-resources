# manage heroku-postgresql databases
#
class Heroku::Command::Pg < Heroku::Command::Base

  # pg:credentials DATABASE
  #
  # Display the DATABASE credentials.
  #
  #   --reset  # Reset credentials on the specified database.
  #
  def credentials
    unless db = shift_argument
      error("Usage: heroku pg:credentials DATABASE\nMust specify DATABASE to display credentials.")
    end
    validate_arguments!

    name, url = hpg_resolve(db)

    if options[:reset]
      action "Resetting credentials for #{name}" do
        hpg_client(url).rotate_credentials
      end
    else
      uri = URI.parse(url)
      display "Connection info string:"
      display "   \"dbname=#{uri.path[1..-1]} host=#{uri.host} port=#{uri.port || 5432} user=#{uri.user} password=#{uri.password} sslmode=require\""
    end
  end

end
