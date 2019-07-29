Pod::Spec.new do |s|
  s.name = 'DataRaft'
  s.version = '1.0.3'
  
  s.summary = 'DataRaft is a small Swift framework that makes it both easier to use Core Data.'
  s.homepage = 'https://github.com/nullgr/data-raft.git'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.author = { 'Aleksey Zgurskiy' => 'mr.noone@icloud.com' }
  
  s.platform = :ios, '8.0'
  
  s.source = { :git => 'https://github.com/nullgr/data-raft.git', :tag => "#{s.version}" }
  s.source_files = 'DataRaft/DataRaft/**/*.{swift}'
  s.swift_version = '5.0'
end
