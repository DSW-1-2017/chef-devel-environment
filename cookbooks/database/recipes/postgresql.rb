package 'postgresql'
package 'libpq-dev'

codemat_user = node['user']['name']

template '/etc/postgresql/9.4/main/pg_hba.conf' do
  source 'pg_hba.conf.erb'
  owner 'postgres'
  group 'postgres'
  mode 0644
  variables({
    user_dev: codemat_user,
    user_app: codemat_user,
  })
end

service 'postgresql' do
  action [:enable, :start]
end

execute "creating postgres' users for #{codemat_user}" do
  psql_command = "CREATE USER #{codemat_user} with createdb login password '#{node['passwd']['postgresql']}'"
  command "psql -U postgres -c #{ '"' + psql_command + '"' }"
  user 'postgres'
  ignore_failure true
end

service 'postgresql' do
  action [:restart]
end
