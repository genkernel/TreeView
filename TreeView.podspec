#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TreeView'
  s.version          = '1.1.3'

  s.platform     = :ios, '8.0'
  s.ios.deployment_target = '8.0'
  s.requires_arc = true

  s.summary          = 'Sub-cells simplified. ©'
  s.description      = <<-DESC
TreeView is a "proxy" object that sits between UITableView and UIViewController, 
proxies all calls to data source and converts 2d-like indexPaths (0-0, 0-1, ...) into N-depth indexPaths (0-0, 0-0-1, 0-0-2, 0-1-0-1, ...)
so you can have nested subcells within native UITableView.
                       DESC

  s.homepage         = 'https://github.com/genkernel/TreeView'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'kernel' => 'kernel@reimplement.mobi' }
  s.source           = { :git => 'https://github.com/genkernel/TreeView.git', :tag => s.version.to_s }

  s.source_files = "TreeTable/*.{h,m}"

  s.requires_arc = true
end
