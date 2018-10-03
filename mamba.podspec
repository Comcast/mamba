Pod::Spec.new do |s|

s.name              = "mamba"
s.version           = "1.0.7"
s.license           = { :type => 'Apache License, Version 2.0',
                        :text => <<-LICENSE
                            Copyright 2017 Comcast Cable Communications Management, LLC
                            Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file 
                            except in compliance with the License. You may obtain a copy of the License at
                                http://www.apache.org/licenses/LICENSE-2.0
                            Unless required by applicable law or agreed to in writing, software distributed under the 
                            License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, 
                            either express or implied. See the License for the specific language governing permissions 
                            and limitations under the License.
                            This product includes software developed at Comcast (http://www.comcast.com/).
                        LICENSE
                    }
s.homepage          = "https://github.com/Comcast/mamba"
s.summary           = "mamba - a library for parsing, validating and editing HLS manifests"
s.author            = "Comcast"

s.ios.deployment_target     = '9.0'
s.tvos.deployment_target    = '10.0'
s.osx.deployment_target     = '10.13'

s.source            = { :git => "https://github.com/Comcast/mamba.git", :tag => "#{s.version}" }
s.source_files      = 'mambaSharedFramework/**/*.{h,m,swift,c}'
s.preserve_paths    = 'mambaSharedFramework/**/*.include'
s.frameworks        = 'CoreMedia'
s.requires_arc      = true

end
