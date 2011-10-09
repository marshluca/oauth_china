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
    
    def friends_del(name) 
      self.post("http://open.t.qq.com/api/friends/del", {:format => "json", :name => name})
    end

    #TODO
    def upload_image(content, image_path, options = {})
      add_status(content, options)
    end

    #    def upload_image(content, image_path, options = {})
    #      options = options.merge!(:content => content, :pic => File.open(image_path, "rb")).to_options
    #
    #      upload("http://open.t.qq.com/api/t/add_pic", options)
    #    end


  end
end