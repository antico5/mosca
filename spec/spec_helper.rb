require "codeclimate-test-reporter"
ENV['CODECLIMATE_REPO_TOKEN']='188526a5386ffb1697df439556a65c1f1ab2f7889da7452c04220432549248eb'
CodeClimate::TestReporter.start
require 'mosca'
require 'client_double'
