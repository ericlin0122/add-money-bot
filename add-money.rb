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
failed_list = []
passed_list = []
skipped_list = []
b.textarea.when_present.send_keys(["Auto entering contribution now. Please do not type anything here until you see 'bot finished entering contribution.' message.", :enter])
sleep 5
File.readlines(contribution_file_path).each do |text_to_send|
  text_to_send = text_to_send.chomp
  if text_to_send.split(" ").size < 3
    skipped_list << "Skip: #{text_to_send}"
    next
  end
  amount = text_to_send.split(" ").last
  splits = text_to_send.split(" ")
  splits.delete_at(0)
  splits.delete_at(-1)
  user = splits.join(" ").strip[1..-1]
  tries = 0
  begin
    sleep 3
    b.textarea.when_present.send_keys([text_to_send, :enter])
    found = false
    pattern = /Added.+\[#{Regexp.escape(user)}\].+cash/
    10.times do
      begin
        last_div = b.div(:class => /^messagesWrapper.*/).div(:class => /^messages.*/).divs.last
        if last_div.text =~ pattern
          found = true
          passed_list << "#{user} #{amount}"
          puts "sent: #{text_to_send}"
          break
        else
          # sleep 1
        end
      rescue
        puts "error when getting last message"
      end
    end
    raise("unable to send: #{text_to_send}") unless found
  rescue Exception => e
    if tries <= 0
      failed_list << "#{user} #{amount}"
      puts e.message
    else
      tries -= 1
      sleep 3
      retry
    end
  end
end


#print passed
summary = "Successfully added money:\n #{passed_list.join("\n")}"
puts summary
b.textarea.when_present.send_keys(["Successfully added money:", :enter])
sleep 1
passed_list.each do |item|
  b.textarea.when_present.send_keys([item, :enter])
  sleep 1
end
sleep(3)
summary = "Failed to add money:\n #{failed_list.join("\n")}"
puts summary
b.textarea.when_present.send_keys(["Failed to add money:", :enter])
failed_list.each do |item|
  b.textarea.when_present.send_keys([item, :enter])
  sleep 1
end
summary = "Skipped due to improper data:\n #{skipped_list.join("\n")}"
puts summary
b.textarea.when_present.send_keys(["Skipped due to improper data:", :enter])
skipped_list.each do |item|
  b.textarea.when_present.send_keys([item, :enter])
  sleep 1
end
sleep(3)
b.textarea.when_present.send_keys(["bot finished entering contribution.", :enter])
sleep(3)
#logout
b.button(:css => "[aria-label='User Settings']").when_present.click
sleep 5
b.div(:text => "Log Out").when_present.click
sleep 5
b.button(:text => "Log Out").when_present.click
sleep 5
b.text_field(:css => "[type='email']").when_present
puts "logged out"
b.close