require 'yaml'
environment = ENV['CM_ENV'] || "codemat"

config_path = "config/#{environment}"

ssh_config_file =          "#{config_path}/ssh_config"
ips_file =                 "#{config_path}/ips.yaml"
passwd_file =              "#{config_path}/passwd.yaml"
certificate_domains_file = "#{config_path}/certificate_domains.yaml"
user_config_file =         "#{config_path}/user_config"

if environment == "holodev"
  system("mkdir -p config/holodev;"\
         "cd devenv/codemat;"\
         'holodev info | sed -ne "s/IP:\s*/devenv: /p"'\
         " > ../../#{ips_file}.new ;"\
         "cd ../..;"\
         "cp config/codemat/* #{config_path};"\
         "rm -rf #{user_config_file}")

  begin
    ips = YAML.load_file("#{ips_file}.new")
    raise ArgumentError, "Error reading ips file" unless ips.is_a?(Hash)

    FileUtils.mv ips_file + '.new', ips_file

    current_user = ENV['USER']
    system('sed -ie "N;N;s/\(Host devenv\)/\1/;s/\(Hostname\s*\)[0-9.]*/\1' +
           ips['devenv'] + '/g;s/\(User\s*\).*/\1' + current_user + '/g" ' +
           ssh_config_file)

    current_user_home = "/HOLODEV"

  rescue Exception => ex
    puts ex.message
    puts
    puts "Q: did you boot the containers first?"
    exit
  end
else
  current_user = ""
  File.open(user_config_file, 'r') { |f| current_user = f.gets.strip }
  current_user_home = "/home/#{current_user}"
end

ENV['CHAKE_SSH_CONFIG'] = ssh_config_file

require "chake"

ips ||= YAML.load_file(ips_file)
passwords ||= YAML.load_file(passwd_file)
crt_domains ||= YAML.load_file(certificate_domains_file)

$nodes.each do |node|
  node.data['user'] = Hash.new
  node.data['user']['name'] = current_user
  node.data['user']['home'] = current_user_home
  node.data['peers'] = ips
  node.data['passwd'] = passwords
  node.data['crt_domains'] = crt_domains
end

task :preconfig do
  command = "sudo apt-get install -y wget rsync"
  $nodes.each do |node|
    puts "###############################################"
    puts "[#{node.hostname}]: EXECUTING #{command}"
    puts "This can take long"
    puts "###############################################"

    output = IO.popen("ssh -F #{ssh_config_file} #{node.hostname} #{command}")
    output.each_line do |line|
      printf "%s: %s\n", node.hostname, line.strip
    end

    output.close
    if $?
      status = $?.exitstatus
      if status != 0
        raise Exception.new(['FAILED with exit status %d' % status].join(': '))
      end
    end
  end
end

task :clean do
  central_user = `echo $USER`.strip
  sh "rake run['sudo rm -rf /var/tmp/chef.#{central_user}']"
  sh "rm -rf tmp/*"
end

Dir.glob('tasks/*.rake').each { |f| load f }
