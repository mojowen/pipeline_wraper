require 'spec_helper'

RSpec.describe PipelineRequest do
  it 'Easily serializes to a JSON hash' do
    dummy_request = {
      foo: true,
      bar: 'string'
    }

    request = PipelineRequest.new dummy_request

    expect(request.to_json).to eq(dummy_request.to_json)
    expect(request.to_h).to eq(dummy_request)
  end

  it 'Makes requests' do
    data = { some_data: 'goes here' }
    path = '/a/path'

    WebMock.stub_request(:post, "#{ENV['TASK_SERVER_URL']}#{path}")
      .with(body: data).to_return(body: { success: true }.to_json)

    request = PipelineRequest.post data, path
    expect(request['success']).to be_truthy
  end

  it 'Bad status raises an exception' do
    path = '/a/path'

    WebMock.stub_request(:get, "#{ENV['TASK_SERVER_URL']}#{path}")
      .to_return(status: 500, body: { error: ':(' }.to_json)

    expect { PipelineRequest.get(path) }.to raise_error RuntimeError
  end

  it 'Bad json raises an exception' do
    path = '/a/path'

    WebMock.stub_request(:get, "#{ENV['TASK_SERVER_URL']}#{path}")
      .to_return(body: 'not json')

    expect { PipelineRequest.get(path) }.to raise_error RuntimeError
  end
end
