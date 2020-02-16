require 'json'
require 'net/http'
require 'time' 

class Benchmarker 
    attr_accessor :sitemap, :uri

    def initialize(**opts)
        @sitemap = []
        @uri = URI(opts[:uri])
        crawl_page(uri)
    end

    def crawl_page(page)
        response = Net::HTTP.get(page)
        links = response.scan(/href=["'](.*?)["']/).flatten
        links.each do |link|
            link_uri = URI.join("https://www.amitaiforcolorado.com", link)
            if link_uri.host == @uri.host 
                @sitemap.push(link_uri)
            end
        end 
    end

    def check_performance
        @sitemap.uniq.each do |page|
            score_page(page)
        end
    end

    def score_page(url) 
        desktop_endpoint = URI('https://www.googleapis.com/pagespeedonline/v5/runPagespeed?strategy=desktop&url=' + url.to_s)
        mobile_endpoint = URI('https://www.googleapis.com/pagespeedonline/v5/runPagespeed?strategy=mobile&url=' + url.to_s)
        desktop_result = JSON.parse(Net::HTTP.get(desktop_endpoint))
        mobile_result = JSON.parse(Net::HTTP.get(mobile_endpoint))
        desktop_score = desktop_result["lighthouseResult"]["audits"]["speed-index"]["score"]
        mobile_score = mobile_result["lighthouseResult"]["audits"]["speed-index"]["score"]
        puts "#{url.to_s} - Desktop: #{desktop_score}. Mobile: #{mobile_score}"
    end
end

@b = Benchmarker.new({uri: 'https://www.amitaiforcolorado.com'})