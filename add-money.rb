require_relative 'driver'
channel = ENV["channel"]
username = ENV["username"]
password = ENV["password"]
browser_type = ENV["browser_type"]
contribution_file_path = ENV["contribution_file_path"]
driver = Driver.new(true, browser_type)
b = driver.browser
room_uri = "https://discordapp.com/channels/#{channel}"
b.goto(room_uri)
b.text_field(:css => "[type='email']").when_present.set username
b.text_field(:css => "[type='password']").when_present.set password
b.button(:text => "Login").click
File.readlines(contribution_file_path).each do |text_to_send|
  text_to_send = text_to_send.chomp
  user = text_to_send.split(" ")[-2][1..-1]
  tries = 0
  begin
    sleep 3
    b.textarea.when_present.send_keys([text_to_send, :enter])
    found = false
    pattern = /Added.+\[#{user}\].+cash/
    10.times do
      last_div = b.div(:class => /^messagesWrapper.*/).div(:class => /^messages.*/).divs.last
      if last_div.text =~ pattern
        found = true
        puts "sent: #{text_to_send}"
        break
      else
        # sleep 1
      end
    end
    raise("unable to send: #{text_to_send}") unless found
  rescue Exception => e
    if tries <= 0
      puts e.message
    else
      tries -= 1
      sleep 3
      retry
    end
  end
end

#logout
b.button(:css => "[aria-label='User Settings']").when_present.click
sleep 5
b.div(:text => "Log Out").when_present.click
sleep 5
b.button(:text => "Log Out").when_present.click
sleep 5
b.text_field(:css => "[type='email']").when_present
puts "logged out"