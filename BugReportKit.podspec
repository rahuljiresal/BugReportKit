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
    s.version          = '0.1.0'
    s.summary          = 'A short description of BugReportKit.'
    s.description      = <<-DESC
                       An optional longer description of BugReportKit

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
    s.homepage         = 'https://github.com/rahuljiresal/BugReportKit'
    # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
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
        cr.public_header_files = 'Pod/Core/BugReportKit.h', 'Pod/Core/BRKImageUploaderDelegate.h', 'Pod/Core/BRKReporterDelegate.h'
        cr.frameworks = 'UIKit'
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

    s.subspec 'JIRAReporter' do |er|
        er.source_files = 'Pod/Classes/Reporters/JIRA/**/*'
        er.public_header_files = 'Pod/Reporters/JIRA/BRKJIRAReporter.h'
        er.dependency 'BugReportKit/Core'
        er.dependency 'BugReportKit/S3ImageUploader'
    end

end
