module OauthChina
  class Sina < OauthChina::OAuth
      
    def initialize(*args)
      self.consumer_options = {
        :site               => 'http://api.t.sina.com.cn',
        :request_token_path => '/oauth/request_token',
        :access_token_path  => '/oauth/access_token',
        :authorize_path     => '/oauth/authorize',
        :realm              => url
      }
      super(*args)
    end

    def name
      :sina
    end

    def authorized?
      #TODO
    end

    def destroy
      #TODO
    end 
    
    def add_status(content, options = {})
      self.post("http://api.t.sina.com.cn/statuses/update.json", options)
    end

    def friends(id, cursor = -1)  
      body = self.get("http://api.t.sina.com.cn/statuses/friends/#{id}.json?cursor=#{cursor}&count=2")
      puts body
    end
    
    def verify
      body = self.get("http://api.t.sina.com.cn/statuses/account/verify_credentials.json")
      puts body
    end 

    def upload_image(content, image_path, options = {})
      options = options.merge!(:status => content, :pic => File.open(image_path, "rb")).to_options
      upload("http://api.t.sina.com.cn/statuses/upload.json", options)
    end

    

  end
end