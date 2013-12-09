require 'rubygems'
require 'rake'
require 'rdoc'
require 'date'
require 'yaml'
require 'tmpdir'
require 'jekyll'
require "bundler/setup"
require "stringex"

# This will be configured for you when you run config_deploy
deploy_branch = "master"
source_branch = "source"

posts_dir       = "_posts"    # directory for blog files
drafts_dir      = "_drafts"   # directory for draft files
new_post_ext    = "markdown"  # default new post file extension when using the new_post task
new_page_ext    = "markdown"  # default new page file extension when using the new_page task

editor = "subl"


task :default => :watch


desc "compile and run the site"
task :watch do
  pids = [
    spawn("jekyll server -w --drafts"),
    spawn("scss --watch _assets:assets"),
    # spawn("coffee -b -w -o assets -c _assets/*.coffee")
    spawn("coffee -b -w -o assets -c _assets/*.coffee")
  ]

  trap "INT" do
    Process.kill "INT", *pids
    exit 1
  end

  loop do
    sleep 1
  end
end


desc "Generate blog files"
task :generate, :show_drafts do |t, args|
  system "git checkout \"#{source_branch}\""
  Jekyll::Site.new(Jekyll.configuration({
    "source"      => ".",
    "destination" => "_site",
  })).process
end


task :check_git do
  unless git_clean?
    puts "Dirty repo - commit or discard your changes and run deploy again"
    exit 1
  end
end


desc "Deploy to remote origin"
task :deploy => [:check_git] do
  message = "Site updated at #{Time.now.utc}"

  system "git checkout \"#{deploy_branch}\""
  system "cp -r _site/* ."

  unless git_clean?
    system "git add . && git commit -m \"#{message}\""
    system "git push origin \"#{deploy_branch}\" --force"
    puts "Pushed to origin with commit message: #{message}"
  else
    puts "No changes to deploy - canceled"
  end

  system "git checkout \"#{source_branch}\""
end


# usage rake post[my-new-post] or rake post['my new post'] or rake post (defaults to "new-post")
desc "Begin a new post in #{posts_dir}"
task :post, :title do |t, args|
  title = check_title(args.title)
  mkdir_p "#{posts_dir}"
  filename = "#{posts_dir}/#{Time.now.strftime('%Y-%m-%d')}-#{title.to_url}.#{new_post_ext}"
  if File.exist?(filename)
    abort("rake aborted!") if ask("#{filename} already exists. Do you want to overwrite?", ['y', 'n']) == 'n'
  end
  puts "Creating new post: #{filename}"
  open(filename, 'w') do |post|
    post.puts "---"
    post.puts "layout: post"
    post.puts "title: \"#{title.gsub(/&/,'&amp;')}\""
    post.puts "date: #{Time.now.strftime('%Y-%m-%d %H:%M')}"
    post.puts "comments: true"
    post.puts "categories: "
    post.puts "---"
  end
  open_file(filename, eidtor);
end


# rake draft["Title"]
desc "Create a draft in #{drafts_dir}"
task :draft, :title do |t, args|
  title = check_title(args.title)
  mkdir_p "#{drafts_dir}"
  filename = "_drafts/#{Time.now.strftime('%Y-%m-%d')}-#{title.to_url}.#{new_post_ext}"
  if File.exist?(filename)
    abort("rake aborted!") if ask("#{filename} already exists. Do you want to overwrite?", ['y', 'n']) == 'n'
  end
  puts "Creating new draft: #{filename}"
  open(filename, 'w') do |post|
    post.puts "---"
    post.puts "layout: post"
    post.puts "title: \"#{title.gsub(/&/,'&amp;')}\""
    post.puts "date: #{Time.now.strftime('%Y-%m-%d %H:%M')}"
    post.puts "comments: true"
    post.puts "categories: "
    post.puts "---"
  end
  open_file(filename, editor);
end


# rake publish
desc "Move a post from _drafts to _posts"
task :publish do
  files = Dir["#{drafts_dir}/*.#{new_post_ext}"]
  files.each_with_index do |file, index|
    puts "#{index + 1}: #{file}".sub("#{drafts_dir}/", "")
  end
  puts "Please choose a draft by the assigned number."
  print "> "
  number = $stdin.gets
  if number =~ /\D/
    filename = files[number.to_i - 1].sub("#{drafts_dir}/", "")
    FileUtils.mv("#{drafts_dir}/#{filename}", "#{posts_dir}/#{Time.now.strftime('%Y-%m-%d %H:%M')}-#{filename}")
    puts "#{filename} was moved to '#{posts_dir}'."
  end
end


desc 'New blog post notification to Sina Weibo'
task :weibo do
  puts 'Sending post to weibo'
  system 'ruby _custom/sina_weibo.rb'
end


##################
# util functions #
##################
def check_title(t)
  if t
    title = t
  else
    title = get_stdin("Enter a title for your post: ")
  end
  return title;
end


# Create the file with the slug and open the default editor
def open_file(filename, editor)
  if File.exists?(filename)
    if editor && !editor.nil?
      sleep 1
      system "#{editor} #{filename}"
    end
  else
    raise "The file does not exists."
  end
end

def get_stdin(message)
  print message
  STDIN.gets.chomp
end

def ask(message, valid_options)
  if valid_options
    answer = get_stdin("#{message} #{valid_options.to_s.gsub(/"/, '').gsub(/, /,'/')} ") while !valid_options.include?(answer)
  else
    answer = get_stdin(message)
  end
  answer
end

def git_clean?
  git_state = `git status 2> /dev/null | tail -n1`
  clean = (git_state =~ /working directory clean/)
end