unless Capistrano::Configuration.respond_to?(:instance)
  abort "s3-static-site requires Capistrano >= 2."
end

Capistrano::Configuration.instance(true).load do
  def _cset(name, *args, &block)
    set(name, *args, &block) if !exists?(name)
  end
  
  _cset :deployment_path, `pwd`.gsub("\n", "") + "/public/"
  
  def base_file_path(file)
    file.gsub(deployment_path, "")
  end
  
  def upload_files
    establish_connection!
    
    files.each do |file|
      if !File.directory?(file)
        path = base_file_path(file)
        
        puts "Uploading #{path}..."
        
        AWS::S3::S3Object.store(path, open(file), bucket)
      end
    end
  end
  
  def files
    Dir.glob("#{deployment_path}/**/*")
  end
  
  # Establishes the connection to Amazon S3
  def establish_connection!
    AWS::S3::Base.establish_connection!(
      :access_key_id     => access_key_id,
      :secret_access_key => secret_access_key
    )
  end
  
  # Deployment recipes
  namespace :deploy do
    task :update do
      upload_files
    end

    task :restart do; end
  end
end