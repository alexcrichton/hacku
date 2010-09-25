require 'fileutils'

BASE = File.expand_path(File.dirname(__FILE__) + '/../..')

def get_path
  file = ENV['FILE']

  while file.nil? || file == '' do
    print "Enter a file (relative to config/): "
    file = $stdin.gets.strip
  end

  path = "#{BASE}/tmp/downloads/#{file}"

  unless File.directory?(File.dirname(path))
    FileUtils.mkdir_p File.dirname(path), :mode => 0755
  end

  path
end

def user_edit file
  `#{ENV['EDITOR'] || 'vim'} #{file}`
end

def update path
  puts path
  user_edit path
  puts File.exists?(path)
  upload path, "#{shared_path}/config/#{File.basename(path)}"
  File.delete path
end

namespace :config do
  desc "Upload a file"
  task :init, :roles => :app do
    path = get_path

    if File.exists?("#{BASE}/config/#{File.basename(path)}.example")
      `cp #{BASE}/config/#{File.basename(path)}.example #{path}`
    end

    update path
  end

  desc "Edit a file"
  task :edit, :roles => :app do
    path = get_path

    get "#{shared_path}/config/#{File.basename(path)}", path
    update path
  end

end
