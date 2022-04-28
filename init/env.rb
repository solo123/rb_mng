module Ns
  CurrEnv = (ENV.fetch "APP_ENV", "development").downcase
  AppConfig = OpenStruct.new YAML.load_file("./config/app_conf.yml")[CurrEnv]
end
