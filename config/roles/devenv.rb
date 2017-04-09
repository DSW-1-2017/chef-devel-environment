name "devenv"
description "Install and configure rails application @ dev_env on VM"

run_list *[
  'recipe[basics]',
  'recipe[devenv::config]',
]
