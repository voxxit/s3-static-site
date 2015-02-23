require 'haml'
require 'aws/s3'
require 'mime/types'

unless Capistrano::Configuration.respond_to?(:instance)
  abort "s3-static-site requires Capistrano >= 2."
end

Capistrano::Configuration.instance(true).load do
  def _cset(name, *args, &block)
    set(name, *args, &block) if !exists?(name)
  end
  
  _cset :aws_connect_options, {}
  _cset :access_key_id, nil
  _cset :secret_access_key, nil
  _cset :deployment_path, Dir.pwd.gsub("\n", "") + "/public"
  _cset :deploy_to, ""
  
  def base_file_path(file)
    file.gsub(deployment_path, "")
  end
  
  def files
    Dir.glob("#{deployment_path}/**/*")
  end
  
  # Establishes the connection to Amazon S3
  def establish_connection!
    options = {
      :logger => Logger.new(STDOUT) # Send logging to STDOUT
    }.merge(aws_connect_options)
    options[:access_key_id] = access_key_id if access_key_id
    options[:secret_access_key] = secret_access_key if secret_access_key

    AWS.config(options)
    AWS::S3.new
  end
  
  # Deployment recipes
  namespace :deploy do
    namespace :s3 do      
      desc "Empties bucket of all files. Caution when using this command, as it cannot be undone!"
      task :empty do
        _s3 = establish_connection!
        _s3.buckets[bucket].clear!
      end

      desc "Upload files to the bucket in the current state"
      task :upload_files do
        _s3 = establish_connection!

        files.each do |file|
          if !File.directory?(file)
            path = base_file_path(file)
            path.gsub!(/^\//, "") # Remove preceding slash for S3

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

            types = MIME::Types.type_for(File.basename(file))
            if types.empty?
              options = {
                :acl => :public_read
              }
            else
              options = {
                :acl => :public_read,
                :content_type => types[0]
              }
            end

            target = deploy_to.empty? ? path : File.join(deploy_to, path)
            _s3.buckets[bucket].objects[target].write(contents, options)
          end
        end
      end
    end
    
    task :update do
      s3.upload_files
    end

    task :restart do; end
  end
end
