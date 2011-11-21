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
    
    def sign_alone(method, url, token, params = {}) 
      params = params.merge(:oauth_consumer_key => "db8b28a2b7354bd9800b1863484e78e8", :oauth_nonce => nonce, :oauth_signature_method => "HMAC-SHA1", :oauth_timestamp => Time.now.to_i.to_s, :oauth_version => "1.0", :oauth_token => token.token)
      arr = []
      params.keys.sort.each do |key|
        arr << "#{URI::escape(key.to_s)}%3D#{URI::escape(params[key])}"
      end
      
      signature_base_string = "#{method.upcase}&#{URI::escape(url.downcase)}&#{arr.join("%26")}"
      _signature = Base64.encode64(Digest::HMAC.digest(signature_base_string, "5d31e867b0ea5397a0656b8720c5b006&#{token.secret}", ::Digest::SHA1)).chomp.gsub(/\n/, '')
      params[:oauth_signature] = _signature
      params
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

    #TODO
    # def upload_image(content, image_path, options = {})
    #       add_status(content, options)
    #     end

    def upload_image(content, image_path, options = {})
      # options = options.merge!(:content => content, :pic => File.open(image_path, "rb")).to_options
      options = options.merge!(:content => content, :format => "json", :pic => File.open(image_path, "rb")).to_options 

      qq_upload("http://open.t.qq.com/api/t/add_pic", options)
    end


  end
end