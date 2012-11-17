# s3-static-site

> Allows static websites deployment to Amazon S3 website buckets using Capistrano.

## Hosting your website with Amazon S3

S3 provides special website enabled buckets that allows you to deliver website pages directly from S3.
The most important difference is that theses buckets serves an index document (ex. index.html) whenever a user specifies the URL for the root of your website, or a subfolder. And you can point your domain name directly to the S3 bucket cname.

To learn how to setup your website bucket, see [Amazon Documentation](http://docs.amazonwebservices.com/AmazonS3/latest/dev/index.html?HostingWebsiteQS1.html).

## Getting started

Setup capistrano, create a public folder and set your S3 bucket configurations in `deploy.rb`.

    $ capify .
    $ mkdir public
    $ touch config/deploy.rb #see config instructions bellow
    $ cap deploy

### Configuring deployment

s3-static-site overrides the default Capistrano recipes for Rails projects with its own simple s3 publishing scripts.

    # config/deploy.rb
    require 's3-static-site'

    set :bucket, "www.cool-website-bucket.com"
    set :access_key_id, "CHANGETHIS"
    set :secret_access_key, "CHANGETHIS"

If you want to deploy to multiple buckets, have a look at
[Capistrano multistage](https://github.com/capistrano/capistrano/wiki/2.x-Multistage-Extension)
and  configure a bucket per stage configuration.

#### S3 write options

s3-static-site sets files `:content_type` and `:acl` to `:public_read`, add or override with :

    set :bucket_write_options, {
        cache_control: "max-age=94608000, public"
    }

See aws-sdk [S3Object.write doc](http://rubydoc.info/github/amazonwebservices/aws-sdk-for-ruby/master/AWS/S3/S3Object#write-instance_method) for all available options.

### Built-in HAML template rendering and SASS compile
  
On deployment, `.haml` and `.sass` are generated and uploaded (source .haml and .sass are not uploaded).

### Advanced static website generation & assets management

If you wish to manage your assets with a packaging system, a simple way do to it
is using a combination of :

- [Sinatra](https://github.com/sinatra/sinatra) : simple web framework that we extend for our needs
- [Sinatra-AssetPack](https://github.com/rstacruz/sinatra-assetpack) : deals with version management for all kind of assets
- [Sinatra-Static](https://github.com/paulasmuth/sinatra-static) : generate your complete website in `public/`, allowing an `s3-static-site` deployment

IMPORTANT : to achieve `Sinatra-AssetPack` and `Sinatra-Static` compatibility, see [pull request #1](https://github.com/paulasmuth/sinatra-static/pull/1)
or use [a patched fork](https://github.com/hooktstudios/sinatra-static).

Once you get this together, add a capistrano task to trigger website generation before deploy :

    # config/deploy.rb
    before 'deploy' do
      run_locally "bundle exec ruby app.rb"
      run_locally "bundle exec rake assetpack:build"
    end

## Copyright

Copyright (c) 2012 Josh Delsman & miomoba, Inc. See LICENSE.txt for details.