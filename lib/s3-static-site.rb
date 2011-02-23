require 'haml'
require 'aws/s3'

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
    namespace :s3 do      
      desc "Empties bucket of all files. Caution when using this command, as it cannot be undone!"
      task :empty do
        establish_connection!
        
        puts "Emptying bucket..."

        AWS::S3::Bucket.find(bucket).delete_all
      end

      desc "Upload files to the bucket in the current state"
      task :upload_files do
        establish_connection!

        files.each do |file|
          if !File.directory?(file)
            path = base_file_path(file)

            puts "Uploading #{path}..."

            contents = case File.extname(path)
            when ".haml"
              path.gsub!(".haml", "")

              engine = Haml::Engine.new(File.read(file))
              engine.render
            when ".sass"
              path.gsub!(".sass", "")

              engine = Sass::Engine.new(File.read(file))
              engine.render
            else
              open(file)
            end

            AWS::S3::S3Object.store(path, contents, bucket, :access => :public_read)
          end
        end
      end
    end
    
    task :update do
      s3.empty
      s3.upload_files
    end

    task :restart do; end
  end
end