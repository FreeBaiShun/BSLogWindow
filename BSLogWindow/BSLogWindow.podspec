Pod::Spec.new do |s|

s.name         = "BSLogWindow"
s.version      = "0.1"
s.summary      = "A short description of BSLogWindow."
s.description  = <<-DESC
                 一个用来打印信息到屏幕的小工具。
DESC
s.homepage     = "https://github.com/FreeBaiShun"
s.license      = "MIT"
s.author             = { "free" => "851083075@qq.com" }
s.platform     = :ios, "8.0"
s.requires_arc = true
s.source       = { :git => "https://github.com/FreeBaiShun/BSLogWindow.git", :tag => "#{s.version}" }
s1.source_files  = "BSLogWindow", "BSLogWindow/BSLogWindow/*.{h,m}"
s1.dependency 'WMDragView'
end