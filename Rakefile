require 'yaml'
environment = "codemat"

ssh_config_file = "config/#{environment}/ssh_config"
ips_file = "config/#{environment}/ips.yaml"
passwd_file = "config/#{environment}/passwd.yaml"
certificate_domains_file = "config/#{environment}/certificate_domains.yaml"

ENV['CHAKE_SSH_CONFIG'] = ssh_config_file

require "chake"

ips ||= YAML.load_file(ips_file)
passwords ||= YAML.load_file(passwd_file)
crt_domains ||= YAML.load_file(certificate_domains_file)

$nodes.each do |node|
  node.data['peers'] = ips
  node.data['passwd'] = passwords
  node.data['crt_domains'] = crt_domains
end
