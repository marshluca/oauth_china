# -*- coding: utf-8 -*-
module OauthChina
  module Upload
   
    #NOTICE：
    #各个微博字段名可能不统一
    def upload(url, options)
      url  = URI.parse(url)
      http = Net::HTTP.new(url.host, url.port)

      req  = Net::HTTP::Post.new(url.request_uri)
      req  = sign_without_pic_field(req, self.access_token, options)
      req  = set_multipart_field(req, options)

      http.request(req)
    end
    
    #NOTICE：
    #各个微博字段名可能不统一
    def qq_upload(_url, options)
      url  = URI.parse(_url)
      http = Net::HTTP.new(url.host, url.port)
      
      options.merge!(:clientip => "58.208.198.19")

      req  = Net::HTTP::Post.new(url.request_uri)
      req  = sign_without_pic_field(req, self.access_token, options)
      
      
      # /api/t/add_pic?Filename=vank.png&clientip=58.208.198.19&content=%E8%BF%87%E5%93%A6%E5%85%B1&format=json&jing=&oauth_consumer_key=abb5b6664d974468a224be6c699fd283&oauth_nonce=907B718E8A98C21726D208C10F9F77CC&oauth_signature=JfP5wnJlEBGnbTXBHHkLlEchJhE%3D&oauth_signature_method=HMAC-SHA1&oauth_timestamp=1318701830&oauth_token=f3d4613a17ba462282f9f8dc5816a8b4&oauth_version=1.0&wei= HTTP/1.1
      # /api/t/add_pic?oauth_consumer_key=db8b28a2b7354bd9800b1863484e78e8&oauth_token=04cf802ceb4947bfbb7a49ac89d9ba2e&oauth_signature_method=HMAC-SHA1&oauth_timestamp=1318694935&oauth_nonce=dr42HnNilyjzalkDymqHgvOFeyJNdwKY&oauth_version=1.0&oauth_signature=Dc3OJPVBMMX4Azy5i98u%2Bl6Ac%2F0%3D
      path = req.path
      puts path
      #        
      req.instance_variable_set :"@path", "/api/t/add_pic"
      # puts req.path
      oauth_options = {} 
      path.gsub("/api/t/add_pic?", "").split("&").each do |query|
        arr = query.split("=")
        oauth_options[URI::unescape(arr.first).to_sym] = URI::unescape(arr.last)
      end 
      
      req  = set_multipart_field(req, oauth_options.merge(options))
      
      puts req.body
      http.request(req)
    end

    #图片不参与签名
    def sign_without_pic_field(req, access_token, options)
      req.set_form_data(params_without_pic_field(options))
      self.consumer.sign!(req, access_token, params_without_pic_field(options))
      req
    end

    #mutipart编码：http://www.ietf.org/rfc/rfc1867.txt
    def set_multipart_field(req, params)
      multipart_post = Multipart::MultipartPost.new
      multipart_post.set_form_data(req, params)
    end

    def params_without_pic_field(options)
      options.except(:pic)
    end
      
  end
end