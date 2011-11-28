# -*- coding: utf-8 -*-
module OauthChina
  class Qq < OauthChina::OAuth

    def initialize(*args)
      self.consumer_options = {
        :site => "https://open.t.qq.com",
        :request_token_path  => "/cgi-bin/request_token",
        :access_token_path   => "/cgi-bin/access_token",
        :authorize_path      => "/cgi-bin/authorize",
        :http_method         => :get,
        :scheme              => :query_string,
        :nonce               => nonce,
        :realm               => url
      }
      super(*args)
    end

    def name
      :qq
    end

    #腾讯的nonce值必须32位随机字符串啊！
    def nonce
      Base64.encode64(OpenSSL::Random.random_bytes(32)).gsub(/\W/, '')[0, 32]
    end

    def authorized?
      #TODO
    end

    def destroy
      #TODO
    end

    def add_status(content, options = {})
      options.merge!(:content => content)
      self.post("http://open.t.qq.com/api/t/add", options)
    end

    def idollist(page, reqnum = 200)
      startindex = reqnum * (page-1)
      self.get("http://open.t.qq.com/api/friends/idollist_s?format=json&reqnum=#{reqnum}&startindex=#{startindex}").body
    end

    def fanslist(page, reqnum = 200)
      startindex = reqnum * (page-1)
      self.get("http://open.t.qq.com/api/friends/fanslist_s?format=json&reqnum=#{reqnum}&startindex=#{startindex}").body
    end

    def check_fans(names)   self.get("http://open.t.qq.com/api/friends/check?format=json&names=#{names.join(",")}&flag=0").body
    end

    def friends_del(name)
      self.post("http://open.t.qq.com/api/friends/del", {:format => "json", :name => name})
    end

    CRLF = "\r\n"

    # Encodes the request as multipart
    def add_multipart_data(req,params)
      boundary = Time.now.to_i.to_s(16)
      req["Content-Type"] = "multipart/form-data; boundary=#{boundary}"
      body = ""
      params.each do |key,value|
        esc_key = CGI.escape(key.to_s)
        body << "--#{boundary}#{CRLF}"
        if value.respond_to?(:read)
          body << "Content-Disposition: form-data; name=\"#{esc_key}\"; filename=\"#{File.basename(value.path)}\"#{CRLF}"
          #TODO
          body << "Content-Type: image/jpg#{CRLF*2}"
          body << value.read
        else
          body << "Content-Disposition: form-data; name=\"#{esc_key}\"#{CRLF*2}#{value}"
        end
        body << CRLF
      end
      body << "--#{boundary}--#{CRLF*2}"
      req.body = body
      req["Content-Length"] = req.body.size
    end

    def upload_image_old(content, image_path, options = {})
      options.merge!(
        :clientip => '58.96.96.58',
        :content => content,
        :format => "json",
        :pic => File.open(image_path, "rb"),
        :scheme => 'body',
        :unsigned_parameters => [:pic, :scheme, :oauth_body_hash]
      ).to_options!

      # /api/t/add_pic can only be accessed via http, not https
      self.consumer_options[:site] = "http://open.t.qq.com"

      url = URI.parse("http://open.t.qq.com/api/t/add_pic")

      req = Net::HTTP::Post.new(url.request_uri)

      req.set_form_data(options.except(:pic, :scheme, :unsigned_parameters, :oauth_body_hash))

      # before sign, reload cosumer, so we generate a correct oauth_signature with http, not https URL
      consumer(true).sign!(req, access_token, options)

      options.merge!(req.oauth_helper.parameters_with_oauth).to_options!

      add_multipart_data(req, options.except(:scheme, :unsigned_parameters, :oauth_body_hash))

      res = consumer.http.request(req)
    end


    def upload_image(content, image_path, options = {})
      # /api/t/add_pic can only be accessed via http, not https
      self.consumer_options[:site] = "http://open.t.qq.com"

      request_options = {:scheme => :body, :multipart => true, :unsigned_parameters => [:pic]}

      options.merge!({:clientip => '127.0.0.1',
        :content => content,
        :format => 'json',
        :pic => File.open(image_path, 'rb')
      })

      # reload consumer for the :site change (https -> http)
      consumer(true).request(:post,
                             '/api/t/add_pic',
                             access_token,
                             request_options,
                             options)
    end

  end
end

