#
# Be sure to run `pod lib lint BugReportKit.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'BugReportKit'
    s.version          = '0.1.3'
    s.summary          = 'Easier bug reports on iOS.'
    s.description      = <<-DESC
                       Easier bug reports on iOS. Just take a screenshot in your app, doodle on the image, and send it away! The report will contain device metadata including device model, iOS version, jailbreak status, memory, disk and battery usage status, carrier and WiFi names and a unique user identifier (if set by developer). Currently, Bug reports can be added to Github Issues, JIRA issues, Gitlab Issues, or sent as emails.

                       For more details, check out the Github repo -- https://github.com/rahuljiresal/BugReportKit
                       DESC
    s.homepage         = 'https://github.com/rahuljiresal/BugReportKit'
    s.screenshots     = 'https://cloud.githubusercontent.com/assets/216346/9147661/06328b94-3d1f-11e5-829f-bbda3ceb9856.gif', 'https://cloud.githubusercontent.com/assets/216346/9147888/c91bfb24-3d22-11e5-9d43-151d08ae7129.png', 'https://cloud.githubusercontent.com/assets/216346/9147889/c937381c-3d22-11e5-89e7-152c18e3b6f3.png'
    s.license          = 'MIT'
    s.author           = { 'Rahul Jiresal' => 'rahul.jiresal@gmail.com' }
    s.source           = { :git => 'https://github.com/rahuljiresal/BugReportKit.git', :tag => s.version.to_s }
    s.social_media_url = 'https://twitter.com/rahuljiresal'

    s.platform     = :ios, '7.0'
    s.requires_arc = true

    s.resource_bundles = {
    'BugReportKit' => ['Pod/Assets/*.png']
    }
    
    s.default_subspec = 'Core'
    
    s.subspec 'Core' do |cr|
        cr.source_files = 'Pod/Classes/Core/**/*'
        cr.public_header_files = 'Pod/Core/BRK.h'
        cr.dependency 'GBDeviceInfo'
        cr.frameworks = 'UIKit', 'CoreTelephony', 'SystemConfiguration'
    end        

    s.subspec 'S3ImageUploader' do |er|
        er.source_files = 'Pod/Classes/ImageUploader/**/*'
        er.public_header_files = 'Pod/ImageUploader/*.h'
        er.dependency 'AWSS3', '2.2.3'
        er.dependency 'BugReportKit/Core'
    end

    s.subspec 'EmailReporter' do |er|
        er.source_files = 'Pod/Classes/Reporters/Email/**/*'
        er.public_header_files = 'Pod/Reporters/Email/BRKEmailReporter.h'
        er.dependency 'mailcore2-ios'
        er.dependency 'BugReportKit/Core'
    end

    s.subspec 'GithubReporter' do |er|
        er.source_files = 'Pod/Classes/Reporters/Github/**/*'
        er.public_header_files = 'Pod/Reporters/Github/BRKGithubReporter.h'
        er.dependency 'BugReportKit/Core'
        er.dependency 'BugReportKit/S3ImageUploader'
    end

    s.subspec 'GitlabReporter' do |er|
        er.source_files = 'Pod/Classes/Reporters/Gitlab/**/*'
        er.public_header_files = 'Pod/Reporters/Gitlab/BRKGithubReporter.h'
        er.dependency 'BugReportKit/Core'
        er.dependency 'BugReportKit/S3ImageUploader'
    end

    s.subspec 'JIRAReporter' do |er|
        er.source_files = 'Pod/Classes/Reporters/JIRA/**/*'
        er.public_header_files = 'Pod/Reporters/JIRA/BRKJIRAReporter.h'
        er.dependency 'BugReportKit/Core'
        er.dependency 'BugReportKit/S3ImageUploader'
    end

end
