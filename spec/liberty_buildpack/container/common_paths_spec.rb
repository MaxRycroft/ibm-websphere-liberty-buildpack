# Encoding: utf-8
# IBM WebSphere Application Server Liberty Buildpack
# Copyright 2014 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.

require 'spec_helper'
require 'liberty_buildpack/container/common_paths'

module LibertyBuildpack::Container

  describe CommonPaths do

    HEROKU_ENV_VAR = 'DYNO'.freeze

    before do
      $stdout = StringIO.new
      $stderr = StringIO.new

    end

    after do
      $stdout = STDOUT
      $stderr = STDERR
    end

    describe 'logs and dumps' do
      it 'should default to the root' do
         common_paths =  CommonPaths.new

         expect(common_paths.instance_variable_get(:@relative_location)).to eq('.')
         expect(common_paths.log_directory).to eq('./logs')
         expect(common_paths.dump_directory).to eq('./dumps')
      end

      it 'should provide logs and dumps directories from specified relative location' do
         common_paths =  CommonPaths.new
         common_paths.relative_location = '../'

         expect(common_paths.instance_variable_get(:@relative_location)).to eq('../')
         expect(common_paths.log_directory).to eq('../logs')
         expect(common_paths.dump_directory).to eq('../dumps')
      end

      it 'should provide logs and dumps directories from specified relative location with appended file separator' do
         common_paths =  CommonPaths.new
         common_paths.relative_location = '..'

         expect(common_paths.instance_variable_get(:@relative_location)).to eq('..')
         expect(common_paths.log_directory).to eq('../logs')
         expect(common_paths.dump_directory).to eq('../dumps')
      end

    end

    describe 'buildpack diagnostics directory' do
      context 'when app subdir exists' do
        it 'should provide the diagnostics directory based off the app dir as a default' do
           common_paths =  CommonPaths.new

           expect(common_paths.diagnostics_directory).to eq('./app/.buildpack-diagnostics')
        end

        it 'should provide the diagnostics directory based off the appdir of a customized relatived dir' do
           common_paths =  CommonPaths.new
           common_paths.relative_location = '..'
           expect(common_paths.diagnostics_directory).to eq('../app/.buildpack-diagnostics')
        end
      end

      context 'when app subdir does not exist' do
        before do
          ENV[HEROKU_ENV_VAR] = 'dyno'
        end

        after(:each) do
          ENV[HEROKU_ENV_VAR] = nil
        end

        it 'should provide the diagnostics directory based off the default directory' do
           common_paths =  CommonPaths.new

           expect(common_paths.diagnostics_directory).to eq('./.buildpack-diagnostics')
        end

        it 'should provide the diagnostics directory based off the customized relatived dir' do
           common_paths =  CommonPaths.new
           common_paths.relative_location = '..'

           expect(common_paths.diagnostics_directory).to eq('../.buildpack-diagnostics')
        end
      end

    end # end of buildpack diagnostic

    it 'should raise an error for invalid relative_location' do
      INVALID_PATH_ERROR = 'relative_location provided to common_paths must have a valid path value'.freeze
      common_paths =  CommonPaths.new

      expect { common_paths.relative_location = nil }.to raise_error(INVALID_PATH_ERROR)
      expect { common_paths.relative_location = '' }.to raise_error(INVALID_PATH_ERROR)
      expect { common_paths.relative_location = ' ' }.to raise_error(INVALID_PATH_ERROR)
    end

  end

end
