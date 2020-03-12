require "totem"
# TODO make constants local or always retrieve from environment variables
# TODO Move constants out
CNF_DIR = "cnfs"
TOOLS_DIR = "tools"
# CONFIG = Totem.from_file "./config.yml"

def check_args(args)
  check_verbose(args)
end

def check_verbose(args)
  if ((args.raw.includes? "verbose") || (args.raw.includes? "v"))
    true
  else 
    false
  end
end

def cnf_conformance_yml
  cnf_conformance = `find cnfs/* -name "cnf-conformance.yml"`.split("\n")[0]
  if cnf_conformance.empty?
    raise "No cnf_conformance.yml found! Did you run the setup task?"
  end
  Totem.from_file "./#{cnf_conformance}"
end

def sample_conformance_yml(sample_dir)
  cnf_conformance = `find #{sample_dir}/* -name "cnf-conformance.yml"`.split("\n")[0]
  if cnf_conformance.empty?
    raise "No cnf_conformance.yml found in #{sample_dir}!"
  end
  Totem.from_file "./#{cnf_conformance}"
end

def wait_for_install(deployment_name, wait_count=180)
  second_count = 0
  current_replicas = `kubectl get deployments #{deployment_name} -o=jsonpath='{.status.readyReplicas}'`
  all_deployments = `kubectl get deployments`
  puts all_deployments
  until (current_replicas.empty? != true && current_replicas.to_i > 0) || second_count > wait_count
    puts "second_count = #{second_count}"
    all_deployments = `kubectl get deployments`
    puts all_deployments
    sleep 1
    current_replicas = `kubectl get deployments #{deployment_name} -o=jsonpath='{.status.readyReplicas}'`
    second_count = second_count + 1 
  end
end 
def sample_setup_args(sample_dir, args, deploy_with_chart=true, verbose=false)
  # # Parse the cnf-conformance.yml
  config = sample_conformance_yml(sample_dir)

  if args.named.keys.includes? "release_name"
    release_name = "#{args.named["release_name"]}"
  else
    release_name = "#{config.get("release_name").as_s?}"
  end
  puts "release_name: #{release_name}" if verbose

  if args.named.keys.includes? "deployment_name"
    deployment_name = "#{args.named["deployment_name"]}"
  else
    deployment_name = "#{config.get("deployment_name").as_s?}" 
  end
  puts "deployment_name: #{deployment_name}" if verbose

  if args.named.keys.includes? "helm_chart"
    helm_chart = "#{args.named["helm_chart"]}"
  else
    helm_chart = "#{config.get("helm_chart").as_s?}" 
  end
  puts "helm_chart: #{helm_chart}" if verbose

  if args.named.keys.includes? "helm_directory"
    helm_directory = "#{args.named["helm_directory"]}"
  else
    helm_directory = "#{config.get("helm_directory").as_s?}" 
  end
  puts "helm_directory: #{helm_directory}" if verbose

  if args.named.keys.includes? "git_clone_url"
    git_clone_url = "#{args.named["git_clone_url"]}"
  else
    # TODO check type (any) before doing .as_s 
    git_clone_url = "#{config.get("git_clone_url").as_s?}"
  end
  puts "git_clone_url: #{git_clone_url}" if verbose

  sample_setup(sample_dir: sample_dir, release_name: release_name, deployment_name: deployment_name, helm_chart: helm_chart, helm_directory: helm_directory, git_clone_url: git_clone_url, deploy_with_chart: deploy_with_chart, verbose: verbose )

end

def sample_setup(sample_dir, release_name, deployment_name, helm_chart, helm_directory, git_clone_url="", deploy_with_chart=true, verbose=false)

  current_dir = FileUtils.pwd 
  puts current_dir if verbose 

  destination_cnf_dir = "#{current_dir}/#{CNF_DIR}/#{short_sample_dir(sample_dir)}"
  puts "destination_cnf_dir: #{destination_cnf_dir}" if verbose 
  FileUtils.mkdir_p(destination_cnf_dir) 
  # TODO enable recloning/fetching etc
  # TODO pass in block
  git_clone = `git clone #{git_clone_url} #{destination_cnf_dir}/#{release_name}` if git_clone_url.empty? == false
  puts git_clone if verbose

  # Copy the cnf-conformance.yml
  # yml_cp = `cp #{sample_dir}/cnf-conformance.yml #{destination_cnf_dir}`
  # Copy the sample 
  yml_cp = `cp -a #{sample_dir} #{CNF_DIR}`
  puts yml_cp if verbose

  raise "Copy of #{sample_dir}/cnf-conformance.yml to #{destination_cnf_dir} failed!" unless $?.success?

  begin

    helm = "#{current_dir}/#{TOOLS_DIR}/helm/linux-amd64/helm"
    puts helm if verbose
    if deploy_with_chart
      puts "deploying with chart" if verbose 
      helm_install = `#{helm} install #{release_name} #{helm_chart}`
      puts helm_install if verbose 

      # Retrieve the helm chart source
      FileUtils.mkdir_p("#{destination_cnf_dir}/#{helm_directory}") 
      helm_pull = `#{helm} pull #{helm_chart}`
      puts helm_pull if verbose 
      # core_mv = `mv #{release_name}-*.tgz #{destination_cnf_dir}/#{helm_directory}`
      # TODO helm_chart should be helm_chart_repo
      puts "mv #{chart_name(helm_chart)}-*.tgz #{destination_cnf_dir}/#{helm_directory}" if verbose
      core_mv = `mv #{chart_name(helm_chart)}-*.tgz #{destination_cnf_dir}/#{helm_directory}`
      puts core_mv if verbose 

      puts "cd #{destination_cnf_dir}/#{helm_directory}; tar -xvf #{destination_cnf_dir}/#{helm_directory}/#{chart_name(helm_chart)}-*.tgz" if verbose
      tar = `cd #{destination_cnf_dir}/#{helm_directory}; tar -xvf #{destination_cnf_dir}/#{helm_directory}/#{chart_name(helm_chart)}-*.tgz`
      puts tar if verbose

      puts "mv #{destination_cnf_dir}/#{helm_directory}/#{chart_name(helm_chart)}/* #{destination_cnf_dir}/#{helm_directory}" if verbose
      move_chart = `mv #{destination_cnf_dir}/#{helm_directory}/#{chart_name(helm_chart)}/* #{destination_cnf_dir}/#{helm_directory}`
      puts move_chart if verbose
    else
      puts "deploying with helm directory" if verbose 
      helm_install = `#{helm} install #{release_name} #{destination_cnf_dir}/#{helm_directory}`
      puts helm_install if verbose 
    end

    wait_for_install(deployment_name)
    if helm_install.to_s.size > 0 # && helm_pull.to_s.size > 0
      puts "Successfully setup #{release_name}".colorize(:green)
    end
  ensure
    cd = `cd #{current_dir}`
    puts cd if verbose 
  end
end

def sample_cleanup(sample_dir, verbose=true)
  config = sample_conformance_yml(sample_dir)
  release_name = config.get("release_name").as_s 

  current_dir = FileUtils.pwd 
  helm = "#{current_dir}/#{TOOLS_DIR}/helm/linux-amd64/helm"
  puts helm if verbose 
  helm_uninstall = `#{helm} uninstall #{release_name}`
  puts helm_uninstall if verbose
  destination_cnf_dir = "#{current_dir}/#{CNF_DIR}/#{short_sample_dir(sample_dir)}"
  rm = `rm -rf #{destination_cnf_dir}`
  puts rm if verbose
end

def chart_name(helm_chart_repo)
  helm_chart_repo.split("/").last 
end

def short_sample_dir(full_sample_dir)
  full_sample_dir.split("/").last 
end
