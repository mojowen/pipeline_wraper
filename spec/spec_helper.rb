require 'byebug'
require 'digest'
require 'webmock/rspec'

require_relative '../pipeline_request'
require_relative '../task'
require_relative '../run_import_read_set'

ENV['TASK_SERVER_URL'] = 'http://example.net'
ENV['TASK_AUTH_TOKEN'] = 'My Auth Token'

def task_factory(sub_tasks_count: 0, input_count: 0, sub_tasks: [], inputs: [])
  id = id_factory

  sub_tasks += (0..sub_tasks_count - 1).map { task_factory(inputs: [id]) }
  inputs += (0..input_count - 1).map { task_factory }

  sub_tasks = Hash[sub_tasks.map.with_index{ |el, i| [i, el] }]
  inputs = Hash[inputs.map.with_index{ |el, i| [i, el] }]

  # Create stubbed endpoint for task information in tests
  WebMock.stub_request(:get, "#{ENV['TASK_SERVER_URL']}/tasks/#{id}/")
    .to_return(body: { sub_tasks: sub_tasks, inputs: inputs, id: id}.to_json)

  id
end

def id_factory
  random_string = (0...8).map { (65 + rand(26)).chr }.join
  Digest::SHA1.hexdigest(random_string)[14,40]
end
