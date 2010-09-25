desc "check production log files"
task :logs, :roles => :app do
  stream "tail -f -n100 #{shared_path}/log/#{rails_env}.log"
end

desc "remotely console"
task :console, :roles => :app do
  input = ''
  run "cd #{current_path} && bundle exec rails c #{rails_env}" do |channel, stream, data|
    next if data.chomp == input.chomp || data.chomp == ''
    print data
    channel.send_data(input = $stdin.gets) if data =~ /^(>|\?)>/
  end
end
