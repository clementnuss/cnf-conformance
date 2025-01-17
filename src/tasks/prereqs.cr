require "sam"
require "file_utils"
require "colorize"
require "totem"
require "./utils/system_information/helm.cr"
require "./utils/system_information/wget.cr"
require "./utils/system_information/curl.cr"
require "./utils/system_information/kubectl.cr"

task "prereqs" do  |_, args|
  if helm_installation.includes?("helm found") &&
      wget_installation.includes?("wget found") &&
      curl_installation.includes?("curl found") &&
      kubectl_installation.includes?("kubectl found")
      stdout_success "All prerequisites found."
  else
    stdout_failure "Setup failed. Some prerequisites are missing. Please install all of the prerequisites before continuing."
    exit 1
  end
end

