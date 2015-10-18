class Task < PipelineRequest
  def self.create(task_id)
    new get_task(task_id)
  end

  def self.get_task(task_id)
    get "/tasks/#{task_id}/"
  end

  def inputs_synced(recurse = false)
    @inputs_synced ||= Hash[inputs.map do |input, input_id|
      task = self.class.create(input_id)
      task.sync_sub_tasks if recurse
      [input, task]
    end]
  end

  def sub_tasks_synced(recurse = true)
    @sub_tasks_synced ||= Hash[sub_tasks.map do |sub_task, sub_task_id|
      task = self.class.create(sub_task_id)
      task.sync_sub_tasks if recurse
      [sub_task, task]
    end]
  end

  def task_id
    id.slice 0, 7
  end
end
