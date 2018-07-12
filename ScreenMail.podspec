Pod::Spec.new do |s|
  s.name         = "ScreenMail"
  s.version      = "0.0.1"
  s.summary      = "A short description of ScreenMail."
  s.description  = <<-DESC
  A much much longer description of ScreenMail.
                   DESC
  s.homepage     = "none"
  s.license      = "Copyleft"
  s.author       = { "Jake" => "jbova@jarustech.com" }
  # s.source       = { :path => '.' }
  s.source       = { :git => "https://github.com/cake-dev/ScreenMail.git" }
  s.source_files  = "ScreenMail/Source/*.{swift, h}"
  s.swift_version = "4.0"
  s.platform     = :ios, "9.0"
end