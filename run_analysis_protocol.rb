class RunAnalysisProtocol < PipelineRequest
  def self.create(pipeline_config, result)
    pipeline_request = new(pipeline_config)
    pipeline_request.inputs['read_set'] = result.read_sets.first.task_id
    pipeline_request.inputs['baseline'] = result.baseline.task_id

    pipeline_request
  end
end
