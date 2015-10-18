class RunImportReadSet < PipelineRequest
  @pipeline_template = {
    api_version: '0.1',
    executor_name: 'karius.import_data.illumina.reads.ImportReadSet',
    executor_type: 'python',
    inputs: {},
    params: {
      index_sequence: nil,
      lane: nil,
      read1_path: nil,
      read2_path: nil,
      readu_path: nil,
      run_name: nil
    },
    result_version: '1'
  }

  def self.create(**read_set_params)
    pipeline_request = new @pipeline_template
    pipeline_request[:params].update read_set_params
    pipeline_request
  end
end
