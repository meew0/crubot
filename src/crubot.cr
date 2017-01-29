require "./crubot/*"
require "kemal"
require "discordcr"
require "json"

auth_lines = File.read("crubot-auth").lines

client = Discord::Client.new token: auth_lines[0].strip, client_id: auth_lines[1].strip.to_u64

unless File.exists?("crubot-links")
  File.write("crubot-links", "{}")
end

links = Hash(String, Array(UInt64)).from_json(File.read("crubot-links"))
secret_token = auth_lines[2].strip

client.on_message_create do |event|
  if event.content.starts_with? "crubot, link this: "
    name = event.content.split(":")[1].strip
    links[name] ||= [] of UInt64
    links[name] << event.channel_id
    File.write("crubot-links", links.to_json)
    client.create_message event.channel_id, "Linked repo #{name} to <##{event.channel_id}> (`#{event.channel_id}`)"
  end
end

get "/webhook" do
  "Hooray! The bot works. #{links.size} links are currently registered."
end

post "/webhook" do |env|
  body = env.request.body.not_nil!.gets_to_end

  puts body
  puts env.request.headers["X-Hub-Signature"]

  unless verify_signature(body, env.request.headers["X-Hub-Signature"], secret_token)
    puts "Failed to verify signature! Ignoring packet."
    next
  end

  event_name = env.request.headers["X-GitHub-Event"]
  case event_name
  when "issues"
    event = Crubot::IssuesEvent.from_json(body)
  when "create"
    event = Crubot::CreateEvent.from_json(body)
  when "delete"
    event = Crubot::DeleteEvent.from_json(body)
  when "issue_comment"
    event = Crubot::IssueCommentEvent.from_json(body)
  when "pull_request"
    event = Crubot::PullRequestEvent.from_json(body)
  when "push"
    event = Crubot::PushEvent.from_json(body)
  when "fork"
    event = Crubot::ForkEvent.from_json(body)
  when "watch"
    event = Crubot::WatchEvent.from_json(body)
  else
    event = Crubot::BasicEvent.from_json(body)
  end

  repo_name = event.repository.full_name

  if event.is_a? Crubot::BasicEvent
    puts "Got an #{event_name} for repo #{repo_name} that is not supported - ignoring"
  else
    channels = links[repo_name]? || [] of UInt64
    msg = "**#{repo_name}**: **#{event.sender.login}** " + event.to_s
    channels.each do |cid|
      client.create_message(cid, msg)
    end
  end

  ""
end

spawn {
  Kemal.run
}

client.run
